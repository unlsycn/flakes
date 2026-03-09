{ config, lib, ... }:
with lib;
let
  cfg = config.services.openvpn;
  configDir = "/etc/openvpn";
in
{
  # `services.openvpn.enable` was removed by nixpkgs upstream; use `deploy` to avoid conflict
  options.services.openvpn.deploy = mkEnableOption "OpenVPN client tunnel deployment";

  config = mkIf cfg.deploy {
    services.openvpn.servers.caat2.config = "config ${configDir}/caat2.ovpn";

    sops.secrets.openvpn-caat1 = {
      sopsFile = ./caat1.ovpn;
      format = "binary";
      path = "${configDir}/caat1.ovpn";
    };

    sops.secrets.openvpn-caat2 = {
      sopsFile = ./caat2.ovpn;
      format = "binary";
      path = "${configDir}/caat2.ovpn";
    };
  };
}
