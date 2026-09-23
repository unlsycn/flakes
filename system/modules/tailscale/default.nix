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
  config = mkMerge [
    {
      networking.nftables.extraDeletions = ''
        table inet mesh-tailnet-anti-spoof

        delete table inet mesh-tailnet-anti-spoof
      '';
    }

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

      mesh.surfaces.tailnet.interfaces = [ tsCfg.interfaceName ];

      mesh.surfaces.public.allowedUDPPorts = [ tcfg.port ] ++ optional isPeerRelay tcfg.peerRelay.port;

      assertions = [
        {
          assertion = !isPeerRelay || tcfg.peerRelay.port != tcfg.port;
          message = "mesh.tailnet.peerRelay.port must differ from mesh.tailnet.port on relay hosts";
        }
      ];

      networking.nftables.tables."mesh-tailnet-anti-spoof" = {
        family = "inet";
        content = ''
          chain prerouting {
            type filter hook prerouting priority raw; policy accept;

            iifname "lo" ip saddr ${tcfg.prefixes.v4} fib saddr type local return
            iifname "lo" ip6 saddr ${tcfg.prefixes.v6} fib saddr type local return

            iifname != "${tsCfg.interfaceName}" ip saddr ${tcfg.prefixes.v4} drop
            iifname != "${tsCfg.interfaceName}" ip6 saddr ${tcfg.prefixes.v6} drop
          }
        '';
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
