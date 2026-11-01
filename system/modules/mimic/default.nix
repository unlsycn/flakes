{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
with lib;
let
  cfg = config.mesh.nebula.mimic;
  nebulaName = config.mesh.nebula.networkName;
  rotation = config.mesh.nebula.portRotation;
  nebulaUnit = "nebula@${nebulaName}";
  port = config.services.nebula.networks.${nebulaName}.listen.port;
in
{
  options.mesh.nebula.mimic = {
    enable = mkEnableOption ''
      Mimic, which disguises Nebula's UDP transport as TCP on the physical interface.
      Enabling installs the CLI and the kernel module, opens the public surface for
      TCP, and runs one Mimic instance per configured interface with Nebula bound to it.
    '';

    interfaces = mkOption {
      type = types.nonEmptyListOf types.str;
      default = config.mesh.surfaces.public.interfaces;
      description = ''
        Physical interfaces carrying the public traffic to be mangled; defaults to the
        mesh public surface, and every entry must be one of its interfaces. Mimic runs
        one process per interface.
      '';
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion =
            cfg.enable
            -> (cfg.interfaces |> all (interface: elem interface config.mesh.surfaces.public.interfaces));
          message = "mesh.nebula.mimic.interfaces must all be interfaces of mesh.surfaces.public.interfaces";
        }
        {
          assertion = cfg.enable -> config.mesh.nebula.enable;
          message = "mesh.nebula.mimic.enable requires a host participating in the Nebula mesh";
        }
        {
          assertion = cfg.enable -> config.networking.firewall.enable;
          message = "mesh.nebula.mimic.enable requires networking.firewall.enable = true";
        }
      ];
    }

    (mkIf cfg.enable {
      environment.systemPackages = [ pkgs.mimic ];

      boot.extraModulePackages = [
        (pkgs.callPackage ./mimic-kmod.nix {
          inherit (config.boot.kernelPackages) kernel kernelModuleMakeFlags;
        })
      ];
      boot.kernelModules = [
        "sch_ingress"
        "mimic"
      ];

      # Allow Mimic's raw TCP control packets alongside restored UDP.
      mesh.surfaces.public.allowedTCPPorts = [ port ];
      mesh.surfaces.public.allowedTCPPortRanges = optional rotation.enable rotation.pool;

      # Reserve the pool so the kernel never hands those ports out as ephemeral ones.
      boot.kernel.sysctl."net.ipv4.ip_local_reserved_ports" =
        mkIf rotation.enable "${toString rotation.pool.from}-${toString rotation.pool.to}";

      users = {
        users.mimic = {
          isSystemUser = true;
          group = "mimic";
        };
        groups.mimic = { };
      };

      systemd.network.networks."50-nebula".routingPolicyRules =
        optional (config.services.mihomo.enable && config.services.mihomo.tunMode)
          {
            User = "mimic";
            Table = "main";
            Priority = 8999;
            Family = "both";
          };

      systemd.services =
        let
          mimicUnit = interface: "mimic@${utils.escapeSystemdPath interface}";
          mimicUnits = cfg.interfaces |> map (interface: "${mimicUnit interface}.service");
        in
        mkMerge [
          {
            # Nebula must not send unmangled UDP on any interface Mimic fails to cover.
            ${nebulaUnit} = {
              bindsTo = mimicUnits;
              after = mimicUnits;
            };
          }

          (
            cfg.interfaces
            |> map (
              interface:
              let
                device = "sys-subsystem-net-devices-${utils.escapeSystemdPath interface}.device";
                # The source-NAT rule only covers rotated interfaces; the rest leave from the listen port.
                rotated = rotation.enable && elem interface rotation.interfaces;
                mimicConfig = pkgs.writeText "mimic-${interface}.conf" ''
                  # allay's iwlwifi reports NETDEV_XDP_ACT_BASIC=no
                  xdp_mode = skb
                  ${
                    (if rotated then range rotation.pool.from rotation.pool.to else [ port ])
                    |> map (p: "filter = local=0.0.0.0:${toString p}")
                    |> concatStringsSep "\n"
                  }
                  ${optionalString (!rotated) "filter = local=[::]:${toString port}"}
                '';
              in
              nameValuePair (mimicUnit interface) {
                description = "Mimic UDP to TCP obfuscator for the Nebula mesh on ${interface}";
                wantedBy = [
                  "multi-user.target"
                  device
                ];
                bindsTo = [ device ];
                after = [
                  "systemd-modules-load.service"
                  device
                ]
                ++ optional rotated "nebula-source-port-rotate.service";
                wants = [ "${nebulaUnit}.service" ] ++ optional rotated "nebula-source-port-rotate.service";

                serviceConfig = {
                  Type = "notify";
                  ExecStartPre = "${pkgs.coreutils}/bin/test -d /sys/module/mimic";
                  ExecStart = "${lib.getExe pkgs.mimic} run --file ${mimicConfig} ${interface}";
                  Restart = "on-failure";
                  RestartSec = "2s";

                  User = "mimic";
                  Group = "mimic";
                  # Mimic keeps its per-interface lock files in the compiled-in /run/mimic, shared
                  # by every instance, so stopping one must not remove it under the others.
                  RuntimeDirectory = "mimic";
                  RuntimeDirectoryMode = "0750";
                  RuntimeDirectoryPreserve = true;
                  CapabilityBoundingSet = [
                    "CAP_SYS_ADMIN"
                    "CAP_NET_ADMIN"
                    "CAP_NET_BIND_SERVICE"
                    "CAP_NET_RAW"
                  ];
                  AmbientCapabilities = [
                    "CAP_SYS_ADMIN"
                    "CAP_NET_ADMIN"
                    "CAP_NET_BIND_SERVICE"
                    "CAP_NET_RAW"
                  ];
                  LimitMEMLOCK = "infinity";
                  ProtectSystem = "strict";
                };
              }
            )
            |> listToAttrs
          )
        ];
    })
  ];
}
