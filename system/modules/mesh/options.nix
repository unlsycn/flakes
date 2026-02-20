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

    ip = mkOption {
      type = types.str;
      readOnly = true;
      description = "The IP address of this node in the mesh";
      default = calculateNodeIp cfg.nebula.cidr cfg.id;
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

    publicEndpoint = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Public endpoint (IP:port) for lighthouses/relays";
    };

    domain = mkOption {
      type = types.str;
      default = "senesperejo.lan";
      description = "Internal domain for the mesh";
    };

    nebula = {
      enable = lib.mkEnableOption "Nebula Mesh" // {
        default = config.mesh.enable;
      };

      cidr = mkOption {
        type = types.str;
        default = "10.122.133.0/24";
        description = "The CIDR block of the network";
      };
    };
  };
}
