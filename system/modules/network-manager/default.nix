{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  config = lib.mkIf config.networking.networkmanager.enable {
    networking.networkmanager = {
      wifi.backend = "iwd";

      unmanaged = mkIf config.systemd.network.enable [
        "*"
        "except:type:wifi"
      ];
    };

    users.users.${user}.extraGroups = [ "networkmanager" ];
    environment.persistence."/persist" = {
      directories = [ "/etc/NetworkManager/system-connections" ];
    };
  };
}
