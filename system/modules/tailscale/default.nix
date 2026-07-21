{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.mesh;
  tcfg = cfg.tailnet;
  tsCfg = config.services.tailscale;

  isPeerRelay = cfg.roles |> elem "relay";
in
{
  config =
    let
      tailnetAntiSpoofCleanup = ''
        iptables -w -t raw -D PREROUTING -j mesh-tailnet-anti-spoof 2>/dev/null || true
        iptables -w -t raw -F mesh-tailnet-anti-spoof 2>/dev/null || true
        iptables -w -t raw -X mesh-tailnet-anti-spoof 2>/dev/null || true

        ip6tables -w -t raw -D PREROUTING -j mesh-tailnet-anti-spoof 2>/dev/null || true
        ip6tables -w -t raw -F mesh-tailnet-anti-spoof 2>/dev/null || true
        ip6tables -w -t raw -X mesh-tailnet-anti-spoof 2>/dev/null || true
      '';
    in
    mkMerge [
      (mkIf (config.networking.firewall.enable && config.networking.firewall.backend == "iptables") {
        # Workaround for https://github.com/NixOS/nixpkgs/issues/11966
        networking.firewall.extraCommands = mkBefore tailnetAntiSpoofCleanup;
      })

      (mkIf tcfg.enable {
        services.tailscale = {
          enable = true;

          port = tcfg.port;

          openFirewall = false;
          extraSetFlags = [
            "--netfilter-mode=off"
            "--accept-dns=true"
            "--relay-server-port=${if isPeerRelay then toString tcfg.peerRelay.port else ""}"
          ];
        };

        systemd.services.tailscaled-set.serviceConfig.RemainAfterExit = true;

        mesh.surfaces.tailnet.interface = tsCfg.interfaceName;

        mesh.surfaces.public.allowedUDPPorts = [ tcfg.port ] ++ optional isPeerRelay tcfg.peerRelay.port;

        assertions = [
          {
            assertion = config.networking.firewall.backend == "iptables";
            message = "mesh.tailnet anti-spoof rules require networking.firewall.backend = \"iptables\"";
          }
          {
            assertion = !isPeerRelay || tcfg.peerRelay.port != tcfg.port;
            message = "mesh.tailnet.peerRelay.port must differ from mesh.tailnet.port on relay hosts";
          }
        ];

        networking.firewall = {
          extraCommands = ''
            iptables -w -t raw -N mesh-tailnet-anti-spoof
            iptables -w -t raw -I PREROUTING 1 -j mesh-tailnet-anti-spoof
            iptables -w -t raw -A mesh-tailnet-anti-spoof -i lo -s ${tcfg.prefixes.v4} -m addrtype --src-type LOCAL -j RETURN
            iptables -w -t raw -A mesh-tailnet-anti-spoof ! -i ${escapeShellArg tsCfg.interfaceName} -s ${tcfg.prefixes.v4} -j DROP

            ip6tables -w -t raw -N mesh-tailnet-anti-spoof
            ip6tables -w -t raw -I PREROUTING 1 -j mesh-tailnet-anti-spoof
            ip6tables -w -t raw -A mesh-tailnet-anti-spoof -i lo -s ${tcfg.prefixes.v6} -m addrtype --src-type LOCAL -j RETURN
            ip6tables -w -t raw -A mesh-tailnet-anti-spoof ! -i ${escapeShellArg tsCfg.interfaceName} -s ${tcfg.prefixes.v6} -j DROP
          '';
          extraStopCommands = tailnetAntiSpoofCleanup;
        };

        services.mihomo = mkIf config.services.mihomo.enable {
          settings = {
            dns.fake-ip-filter = [
              "+.${tcfg.domain}"
              tcfg.controlHost
              "+.tailscale.com"
            ];
            tun = {
              route-exclude-address = [
                tcfg.prefixes.v4
                tcfg.prefixes.v6
                tcfg.servicePrefixes.v4
                tcfg.servicePrefixes.v6
              ];
              exclude-src-port = [ tcfg.port ] ++ optional isPeerRelay tcfg.peerRelay.port;
              exclude-dst-port = [
                tcfg.port
                tcfg.peerRelay.port
              ];
            };
          };

          routes."Tailnet" = {
            rules = [
              {
                type = "DOMAIN";
                rule = tcfg.controlHost;
                priority = 100;
              }
              {
                type = "IP-CIDR";
                rule = tcfg.prefixes.v4;
                priority = 100;
                params = [ "no-resolve" ];
              }
              {
                type = "IP-CIDR6";
                rule = tcfg.prefixes.v6;
                priority = 100;
                params = [ "no-resolve" ];
              }
              {
                type = "IP-CIDR";
                rule = tcfg.servicePrefixes.v4;
                priority = 100;
                params = [ "no-resolve" ];
              }
              {
                type = "IP-CIDR6";
                rule = tcfg.servicePrefixes.v6;
                priority = 100;
                params = [ "no-resolve" ];
              }
              {
                type = "AND";
                rule = "((NETWORK,UDP),(DST-PORT,${toString tcfg.port}))";
                priority = 100;
              }
              {
                type = "AND";
                rule = "((NETWORK,UDP),(SRC-PORT,${toString tcfg.port}))";
                priority = 100;
              }
              {
                type = "AND";
                rule = "((NETWORK,UDP),(DST-PORT,${toString tcfg.peerRelay.port}))";
                priority = 100;
              }
            ]
            ++ optionals isPeerRelay [
              {
                type = "AND";
                rule = "((NETWORK,UDP),(SRC-PORT,${toString tcfg.peerRelay.port}))";
                priority = 100;
              }
            ];
            proxies = [ "DIRECT" ];
            default = "DIRECT";
          };
        };
      })
    ];
}
