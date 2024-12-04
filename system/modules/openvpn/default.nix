{ ... }:
let
  caatConfig = "/etc/openvpn/caat.ovpn";
in
{
  services.openvpn.servers = {
    caat.config = "config ${caatConfig}";
  };

  environment.persistence."/persist" = {
    files = [ caatConfig ];
  };
}
