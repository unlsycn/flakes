{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.systemd.network.enable {
    systemd.network = {
      wait-online.enable = if config.networking.networkmanager.enable then false else true;

      networks = {
        "99-ethernet-default-dhcp" = {
          matchConfig.Type = "ether";
          matchConfig.Kind = "!*";

          networkConfig.DHCP = "yes";
          linkConfig.RequiredForOnline = false;
        };
      };
    };
  };
}
