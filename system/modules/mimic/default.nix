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
  nebulaName = "senesperejo";
  nebulaUnit = "nebula@${nebulaName}";
  port = config.services.nebula.networks.${nebulaName}.listen.port;
  configPath = "/etc/mimic/nebula.conf";
in
{
  options.mesh.nebula.mimic = {
    enable = mkEnableOption ''
      Mimic, which disguises Nebula's UDP transport as TCP on the physical interface.
      Enabling installs the CLI and the kernel module, opens the public surface for
      TCP, and runs Mimic with Nebula bound to it.
    '';

    interface = mkOption {
      type = types.nullOr types.str;
      default =
        config.mesh.surfaces.public.interfaces
        |> (interfaces: if length interfaces == 1 then head interfaces else null);
      description = ''
        Physical interface carrying the public traffic to be mangled. Defaults to the
        single public surface interface, if there is exactly one.
      '';
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion =
            cfg.enable -> cfg.interface != null && elem cfg.interface config.mesh.surfaces.public.interfaces;
          message = "mesh.nebula.mimic.interface must be one of mesh.surfaces.public.interfaces";
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

      environment.etc."mimic/nebula.conf".text = ''
        # allay's iwlwifi reports NETDEV_XDP_ACT_BASIC=no
        xdp_mode = skb
        filter = local=0.0.0.0:${toString port}
        filter = local=[::]:${toString port}
      '';

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

      systemd.services."mimic" = {
        description = "Mimic UDP to TCP obfuscator for the Nebula mesh";
        wantedBy = [ "multi-user.target" ];
        bindsTo = [ "sys-subsystem-net-devices-${utils.escapeSystemdPath cfg.interface}.device" ];
        after = [
          "systemd-modules-load.service"
          "sys-subsystem-net-devices-${utils.escapeSystemdPath cfg.interface}.device"
        ];
        wants = [ "${nebulaUnit}.service" ];

        serviceConfig = {
          Type = "notify";
          ExecStartPre = "${pkgs.coreutils}/bin/test -d /sys/module/mimic";
          ExecStart = "${lib.getExe pkgs.mimic} run --file ${configPath} ${cfg.interface}";
          Restart = "on-failure";
          RestartSec = "2s";

          User = "mimic";
          Group = "mimic";
          RuntimeDirectory = "mimic";
          RuntimeDirectoryMode = "0750";
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
      };

      systemd.services.${nebulaUnit} = {
        bindsTo = [ "mimic.service" ];
        after = [ "mimic.service" ];
      };
    })
  ];
}
