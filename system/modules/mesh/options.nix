{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.mesh;
  nebulaName = "senesperejo";
  nebulaCfg = config.services.nebula.networks.${nebulaName};

  ipToInt =
    ipStr:
    let
      octets = ipStr |> splitString "." |> map toInt;
    in
    (elemAt octets 0) * 16777216
    + (elemAt octets 1) * 65536
    + (elemAt octets 2) * 256
    + (elemAt octets 3);

  intToIp =
    ipInt:
    let
      o1 = ipInt / 16777216;
      rem1 = ipInt - (o1 * 16777216);
      o2 = rem1 / 65536;
      rem2 = rem1 - (o2 * 65536);
      o3 = rem2 / 256;
      o4 = rem2 - (o3 * 256);
    in
    "${toString o1}.${toString o2}.${toString o3}.${toString o4}";

  calculateNodeIp =
    cidr: id:
    (
      cidr
      |> splitString "/"
      |> (l: elemAt l 0)
      |> ipToInt
    )
    + id
    |> intToIp;

  portRange = types.submodule {
    options = {
      from = mkOption { type = types.port; };
      to = mkOption { type = types.port; };
    };
  };
in
{
  options.mesh = {
    id = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "The unique integer ID of this node in the mesh network.";
    };

    roles = mkOption {
      type = types.listOf (
        types.enum [
          "node"
          "lighthouse"
          "relay"
        ]
      );
      default = [ "node" ];
      description = "The roles of this node in the mesh";
    };

    endpoint = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Public endpoint";
    };

    nebula = {
      enable = mkOption {
        type = types.bool;
        readOnly = true;
        default = cfg.id != null;
        description = "Whether this host participates in the Nebula mesh.";
      };

      domain = mkOption {
        type = types.str;
        readOnly = true;
        default = "esper.ejo";
        description = "Internal domain for the nebula mesh";
      };

      cidr = mkOption {
        type = types.str;
        readOnly = true;
        default = "10.122.133.0/24";
        description = "The CIDR block of the network";
      };

      ip = mkOption {
        type = types.nullOr types.str;
        readOnly = true;
        description = "The IP address of this node in the mesh";
        default = if cfg.nebula.enable then calculateNodeIp cfg.nebula.cidr cfg.id else null;
      };

      publicEndpoint = mkOption {
        type = types.nullOr types.str;
        readOnly = true;
        default =
          if cfg.nebula.enable && cfg.endpoint != null then
            "${cfg.endpoint}:${toString nebulaCfg.listen.port}"
          else
            null;
        description = "Public endpoint for lighthouses/relays";
      };
    };

    tailnet = {
      enable = mkEnableOption "Tailnet static capability";

      domain = mkOption {
        type = types.str;
        readOnly = true;
        default = "ts.unlsycn.com";
        description = "Headscale MagicDNS base domain and Tailnet service namespace";
      };

      controlHost = mkOption {
        type = types.str;
        readOnly = true;
        default = "tailnet.unlsycn.com";
        description = "Public Headscale control-plane hostname";
      };

      prefixes = {
        v4 = mkOption {
          type = types.str;
          readOnly = true;
          default = "100.122.0.0/16";
          description = "Static Tailnet IPv4 prefix";
        };

        v6 = mkOption {
          type = types.str;
          readOnly = true;
          default = "fd7a:115c:a1e0::/48";
          description = "Static Tailnet IPv6 prefix";
        };
      };

      servicePrefixes = {
        v4 = mkOption {
          type = types.str;
          readOnly = true;
          default = "100.100.100.100/32";
          description = "Tailscale client-local IPv4 service prefix";
        };

        v6 = mkOption {
          type = types.str;
          readOnly = true;
          default = "fd7a:115c:a1e0::53/128";
          description = "Tailscale client-local IPv6 service prefix";
        };
      };

      port = mkOption {
        type = types.ints.between 1 65535;
        default = 41641;
        description = "tailscaled WireGuard tunnel listen/source port for this host.";
      };

      server.enable = mkEnableOption "Headscale control plane appliance on this host";

      peerRelay = {
        port = mkOption {
          type = types.ints.between 1 65535;
          default = 24242;
          description = "Public UDP port for Tailscale Peer Relay.";
        };
      };
    };

    surfaces = mkOption {
      description = "Host-local mesh surface to interface and firewall projection.";
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            interface = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Host-local interface name for this mesh surface.";
            };

            trusted = mkOption {
              type = types.bool;
              default = false;
              description = "Whether all inbound traffic on this surface is trusted.";
            };

            allowedTCPPorts = mkOption {
              type = types.listOf types.port;
              default = [ ];
              description = "TCP ports allowed on this surface.";
            };

            allowedUDPPorts = mkOption {
              type = types.listOf types.port;
              default = [ ];
              description = "UDP ports allowed on this surface.";
            };

            allowedTCPPortRanges = mkOption {
              type = types.listOf portRange;
              default = [ ];
              description = "TCP port ranges allowed on this surface.";
            };

            allowedUDPPortRanges = mkOption {
              type = types.listOf portRange;
              default = [ ];
              description = "UDP port ranges allowed on this surface.";
            };
          };
        }
      );
    };

    services = mkOption {
      description = "Declarative web services exposure configuration";
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              internalPort = mkOption {
                type = types.nullOr types.port;
                default = null;
                description = "Port where the service is listening locally";
              };

              internalAddress = mkOption {
                type = types.nullOr types.str;
                default = if config.internalPort != null then "127.0.0.1" else null;
                description = "Address where the service is listening locally";
              };

              exposure = {
                nebula = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Expose on Nebula network";
                };
                tailnet = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Expose on Tailnet network";
                };
                public = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Expose on Public Internet";
                };
              };

              singleDomain = mkOption {
                type = types.bool;
                default = false;
                description = "Whether this service must use one canonical domain across planes.";
              };

              domain = mkOption {
                type = types.nullOr types.str;
                readOnly = true;
                description = "Canonical domain for services that have a unique canonical name.";
                default =
                  let
                    e = config.exposure;
                  in
                  if config.singleDomain || (e.tailnet && !e.nebula) then
                    "${name}.${cfg.tailnet.domain}"
                  else if e.nebula && !e.tailnet then
                    "${name}.${cfg.nebula.domain}"
                  else
                    null;
              };

              publicDomain = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Custom public domain for public exposure";
              };

              locations = mkOption {
                type = types.attrs;
                default =
                  if config.internalAddress != null && config.internalPort != null then
                    {
                      "/" = {
                        proxyPass = "http://${config.internalAddress}:${toString config.internalPort}/";
                      };
                    }
                  else
                    { };
                description = "Nginx location configurations";
              };

              extraConfig = mkOption {
                type = types.lines;
                default = "";
                description = "Extra configuration for the nginx virtual host";
              };
            };
          }
        )
      );
    };
  };
}
