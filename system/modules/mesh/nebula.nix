{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.mesh;
  nebulaName = "senesperejo";
  nebulaCfg = config.services.nebula.networks.${nebulaName};

  nodes = inputs.self.mesh-topology |> attrValues;
  generatedDir = ../../hosts/${pkgs.stdenv.hostPlatform.system}/${config.networking.hostName}/_generated;
in
{
  config = mkMerge [
    (mkIf cfg.nebula.enable {
      services.nebula.networks.${nebulaName} = {
        enable = true;
        cert = "${generatedDir}/nebula.crt";
        key = config.sops.secrets.nebula-key.path;
        ca = "${generatedDir}/nebula_ca.crt";

        # manually set port and device to let nixos module generate correct firewall rules
        # and we can reference it in other places
        listen.port = 4242;
        tun.device = nebulaName;

        lighthouses = nodes |> filter (n: n.roles |> elem "lighthouse") |> map (n: n.ip);

        staticHostMap =
          nodes
          |> filter (n: n.publicEndpoint != null)
          |> map (n: {
            name = n.ip;
            value = [ n.publicEndpoint ];
          })
          |> listToAttrs;

        isLighthouse = cfg.roles |> elem "lighthouse";
        isRelay = cfg.roles |> elem "relay";

        firewall = {
          outbound = [
            {
              port = "any";
              proto = "any";
              host = "any";
            }
          ];
          inbound = [
            {
              port = "any";
              proto = "any";
              host = "any";
            }
          ];
        };
      };

      networking.firewall.trustedInterfaces = [
        nebulaCfg.tun.device
      ];

      sops.secrets = {
        nebula-key = {
          sopsFile = "${generatedDir}/nebula.key";
          format = "binary";
          owner = config.systemd.services."nebula@${nebulaName}".serviceConfig.User;
        };
      };

      assertions = [
        {
          assertion = config.systemd.network.enable;
          message = "networkd is needed for nebula to split DNS resolution";
        }
      ];
      systemd.network.networks."50-nebula" = {
        matchConfig.Name = nebulaCfg.tun.device;
        dns = nebulaCfg.lighthouses;
        domains = [ "~${cfg.nebula.domain}" ];
        # Prevent system boot from hanging if the mesh tunnel hasn't established yet
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          # Prevent networkd from dropping IP/routes manually managed by the Nebula binary
          KeepConfiguration = "static";
          # Disable IPv6 Link-Local and DAD to reach the "configured" state
          LinkLocalAddressing = false;
        };
      };

      services.mihomo = mkIf config.services.mihomo.enable {
        settings = {
          dns = {
            fake-ip-filter = [
              "+.${cfg.nebula.domain}"
            ]
            ++ (
              nodes
              |> filter (n: n.publicEndpoint != null)
              |> map (n: n.publicEndpoint |> splitString ":" |> head)
            );
          };

          # Excluding the internal CIDR prevents Mihomo from hijacking DNS queries for internal hosts.
          # Normal mesh traffic bypasses the Mihomo TUN interface via routing policy and never
          # enters the proxy's routing table; this exclusion ensures DNS resolution follows suit.
          # It creates a "hole" in Mihomo's routing table via address space decomposition,
          # forcing excluded traffic to fall back to the main routing table for delivery.
          tun.route-exclude-address = [
            "${cfg.nebula.cidr}"
          ];
        };

        routes."Mesh" = {
          rules = [
            # These rules ensure that Nebula's underlying encrypted UDP traffic is not encapsulated
            # by upstream gateways' proxies. Local traffic already bypasses the local Mihomo TUN
            # via kernel routing policy (suppress_prefixlength 0), so these are primarily for the WAN link.
            {
              type = "DST-PORT";
              rule = nebulaCfg.listen.port |> toString;
              priority = 100;
            }
            {
              type = "SRC-PORT";
              rule = nebulaCfg.listen.port |> toString;
              priority = 100;
            }
          ];
          proxies = [ "DIRECT" ];
          default = "DIRECT";
        };
      };
    })
    (mkIf
      (
        cfg.nebula.enable
        && config.services.mihomo.enable
        && config.services.mihomo.settings.tun.enable
        && (
          [
            "lighthouse"
            "relay"
          ]
          |> any (r: cfg.roles |> elem r)
        )
      )
      (
        let
          mark = 4242;
        in
        {
          # Marking Nebula traffic to use the 'main' table bypasses transparent proxies and prevents source port mangling.
          # While simple clients might tolerate port shifting, Lighthouses and Relays require strict port integrity to
          # maintain session persistence with remote peers; this ensures outgoing handshakes and relayed packets escape
          # the proxy's virtual routing to avoid being re-originated from random ephemeral ports.
          services.nebula.networks.${nebulaName}.settings.listen.so_mark = mark;
          systemd.network.networks."50-nebula".routingPolicyRules = [
            {
              FirewallMark = mark;
              Table = "main";
              Priority = 100;
            }
          ];
        }
      )
    )
  ];

}
