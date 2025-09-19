{ lib, ... }:
let
  configDir = "/etc/openvpn";
in
{
  services.openvpn.servers = lib.mkDefault {
    caat2.config = "config ${configDir}/caat2.ovpn";
  };

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
}
