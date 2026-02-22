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
  nebulaCfg = config.services.nebula.networks.default;

  nodes = inputs.self.mesh-topology |> attrValues;
  generatedDir = ../../hosts/${pkgs.stdenv.hostPlatform.system}/${config.networking.hostName}/_generated;
in
{
  config = mkMerge [
    (mkIf cfg.nebula.enable {
      services.nebula.networks.default = {
        enable = true;
        cert = "${generatedDir}/nebula.crt";
        key = config.sops.secrets.nebula-key.path;
        ca = "${generatedDir}/nebula_ca.crt";

        # manually set port and device to let nixos module generate correct firewall rules
        # and we can reference it in other places
        listen.port = 4242;
        tun.device = "nebula.default";

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
          owner = config.systemd.services."nebula@default".serviceConfig.User;
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
              "+.${cfg.tailnet.domain}"
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
            # These rules ensure that Nebula's underlying encrypteid UDP traffic (Port 4242)
            # is NOT encapsulated by upstream gateways' proxies.
            # Local traffic already bypasses the local Mihomo TUN via kernel routing
            # policy (suppress_prefixlength 0), so these are primarily for the WAN link.
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
      {
        # Prevent the transparent proxy from hijacking Nebula's handshake and relay packets.
        # While source port mangling is tolerated on a pure client (acting like stateful NAT),
        # Lighthouses and Relays act as servers or stateful intermediaries. When replying to
        # handshakes or forwarding relayed traffic, Mihomo's tun auto-route intercepts the
        # outgoing UDP packets and re-originates them via its own network stack, changing the
        # source port from 4242 to a random ephemeral port. Remote nodes drop these packets
        # because they strictly expect traffic from the negotiated port (4242). By setting
        # `listen.so_mark: 4242` in Nebula and adding a higher-priority routing rule, we force
        # all Nebula-originated UDP traffic to bypass the proxy's routing table and use the
        # 'main' table directly, preserving the original source port and session integrity.
        services.nebula.networks.default.settings.listen.so_mark = 4242;
        networking.localCommands = ''
          ip rule add fwmark 4242 lookup main prio 100
        '';
      }
    )
  ];

}
