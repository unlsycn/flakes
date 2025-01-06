{ user, ... }:
{
  imports = [
    ../modules/openvpn
    ../modules/mihomo
  ];

  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    firewall.enable = false;
  };

  services.mihomo.enable = true;

  users.users.${user}.extraGroups = [ "networkmanager" ];

  environment.persistence."/persist" = {
    directories = [ "/etc/NetworkManager/system-connections" ];
  };
}
