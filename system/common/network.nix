{ user, ... }:
{
  imports = [ ../modules/openvpn ];

  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    # proxy.default = "http://127.0.0.1:1970";
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    firewall.enable = false;
  };

  users.users.${user}.extraGroups = [ "networkmanager" ];

  environment.persistence."/persist" = {
    directories = [ "/etc/NetworkManager/system-connections" ];
  };
}
