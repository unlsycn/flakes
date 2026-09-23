{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mesh.nebula.portRotation;

  listenPort =
    config.services.nebula.networks.${config.mesh.nebula.networkName}.listen.port
    |> (
      port:
      if port == null || port == 0 then
        throw "mesh.nebula.portRotation requires a fixed listen port on services.nebula.networks.${config.mesh.nebula.networkName}"
      else
        port
    );

  # One rule per interface: the public surface may list several egress paths, and the underlay
  # leaves through whichever the routing table picks. The leading spaces are the rule's
  # indentation inside the chain below.
  snatRules =
    cfg.interfaces
    |> map (
      interface:
      "  oifname \"${interface}\" udp sport ${toString listenPort} masquerade to :${toString cfg.pool.from}-${toString cfg.pool.to} fully-random"
    )
    |> concatStringsSep "\n";

  rotate = pkgs.writeShellApplication {
    name = "nebula-source-port-rotate";
    runtimeInputs = [ pkgs.conntrack-tools ];
    text = ''
      # Dropping the flow sends the next packet through MASQUERADE again, which then picks a
      # fresh port. conntrack reports failure when nothing matched, which is the normal
      # outcome for an idle tunnel or a flow that already expired.
      if ! output="$(conntrack -D -f ipv4 -p udp --orig-port-src ${toString listenPort} 2>&1)"; then
        case "$output" in
          *"0 flow entries have been deleted."*) ;;
          *)
            printf '%s\n' "$output" >&2
            exit 1
            ;;
        esac
      fi

      printf '%s\n' "$output"
    '';
  };

  portRange = types.submodule {
    options = {
      from = mkOption { type = types.port; };
      to = mkOption { type = types.port; };
    };
  };
in
{
  options.mesh.nebula.portRotation = {
    enable = mkEnableOption ''
      periodic rewriting of Nebula's UDP source port into a pool on the public IPv4 interface, so
      the port seen on the wire stays unpredictable and independent of the listen port
    '';

    interfaces = mkOption {
      type = types.nonEmptyListOf types.str;
      default = config.mesh.surfaces.public.interfaces;
      description = ''
        Public interfaces carrying Nebula underlay traffic; defaults to the mesh public surface,
        and every entry must be one of its interfaces.
      '';
    };

    pool = mkOption {
      type = portRange;
      default = {
        from = 61000;
        to = 61999;
      };
      description = ''
        Inclusive range the translated source port is picked from.
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "3min";
      description = "Minimum time between rotations.";
    };

    randomizedDelay = mkOption {
      type = types.str;
      default = cfg.interval;
      description = "Random delay added to every rotation.";
    };
  };

  config = mkMerge [
    {
      networking.nftables.extraDeletions = ''
        table ip mesh-nebula-snat

        delete table ip mesh-nebula-snat
      '';
    }

    (mkIf cfg.enable {
      assertions = [
        {
          assertion = config.mesh.nebula.enable;
          message = "mesh.nebula.portRotation.enable requires mesh.nebula.enable";
        }
        {
          assertion = all (interface: elem interface config.mesh.surfaces.public.interfaces) cfg.interfaces;
          message = ''
            mesh.nebula.portRotation.interfaces must all be interfaces of mesh.surfaces.public.interfaces
          '';
        }
        {
          assertion = !config.mesh.nebula.mimic.enable;
          message = "mesh.nebula.portRotation currently requires mesh.nebula.mimic.enable = false";
        }
        {
          assertion = !elem "lighthouse" config.mesh.roles && !elem "relay" config.mesh.roles;
          message = "Nebula port rotation is only supported on roaming client nodes";
        }
        {
          assertion = cfg.pool.from < cfg.pool.to;
          message = "mesh.nebula.portRotation.pool must satisfy from < to";
        }
      ];

      networking.nftables.tables."mesh-nebula-snat" = {
        family = "ip";
        content = ''
          chain postrouting {
            type nat hook postrouting priority srcnat;

          ${snatRules}
          }
        '';
      };

      systemd.services.nebula-source-port-rotate = {
        description = "Rotate Nebula's translated UDP source port";
        after = [ "nftables.service" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe rotate;
          CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
        };
      };

      systemd.timers.nebula-source-port-rotate = {
        description = "Periodically rotate Nebula's translated UDP source port";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = cfg.interval;
          OnUnitInactiveSec = cfg.interval;
          RandomizedDelaySec = cfg.randomizedDelay;
        };
      };
    })
  ];
}
