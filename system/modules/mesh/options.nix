{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    splitString
    toInt
    elemAt
    ;
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

  calculateNodeIp = cidr: id: (cidr |> splitString "/" |> (l: elemAt l 0) |> ipToInt) + id |> intToIp;
in
{
  options.mesh = {
    enable = lib.mkEnableOption "Mesh Network";

    id = mkOption {
      type = types.int;
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
      enable = lib.mkEnableOption "Nebula Mesh" // {
        default = config.mesh.enable;
      };

      domain = mkOption {
        type = types.str;
        default = "esper.ejo";
        description = "Internal domain for the nebula mesh";
      };

      cidr = mkOption {
        type = types.str;
        default = "10.122.133.0/24";
        description = "The CIDR block of the network";
      };

      ip = mkOption {
        type = types.str;
        readOnly = true;
        description = "The IP address of this node in the mesh";
        default = calculateNodeIp cfg.nebula.cidr cfg.id;
      };

      publicEndpoint = mkOption {
        type = types.nullOr types.str;
        readOnly = true;
        default =
          if cfg.endpoint != null then "${cfg.endpoint}:${toString nebulaCfg.listen.port}" else null;
        description = "Public endpoint for lighthouses/relays";
      };
    };

    tailnet = {
      enable = lib.mkEnableOption "Tailnet" // {
        default = config.mesh.enable;
      };

      domain = mkOption {
        type = types.str;
        default = "ts.unlsycn.com";
        description = "Internal domain for the tailnet";
      };

      nativeDomain = mkOption {
        type = types.str;
        default = "ts-net.lan";
        description = "Native domain for the tailnet";
      };
    };

    services = mkOption {
      description = "Declarative web services exposure configuration";
      default = { };
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          {
            options = {
              internalPort = mkOption {
                type = types.port;
                description = "Port where the service is listening locally";
              };

              internalAddress = mkOption {
                type = types.str;
                default = "127.0.0.1";
                description = "Address where the service is listening locally";
              };

              expose = {
                nebula = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Expose on Nebula network";
                };
                tailscale = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Expose on Tailscale network";
                };
                public = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Expose on Public Internet";
                };
              };

              publicDomain = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Custom public domain for public exposure";
              };

              locations = mkOption {
                type = types.attrs;
                default = {
                  "/" = {
                    proxyPass = "http://${config.internalAddress}:${toString config.internalPort}/";
                  };
                };
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
