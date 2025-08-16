{
  config,
  lib,
  user,
  ...
}:
{
  config = lib.mkIf config.networking.networkmanager.enable {
    networking.networkmanager.wifi.backend = "iwd";
    users.users.${user}.extraGroups = [ "networkmanager" ];
    environment.persistence."/persist" = {
      directories = [ "/etc/NetworkManager/system-connections" ];
    };
  };
}
