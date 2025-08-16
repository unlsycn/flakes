{ lib, ... }:
with lib;
{
  networking = {
    networkmanager.enable = true;
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    firewall.enable = mkDefault false;
  };

  services = {
    mihomo.enable = true;
    blueman.enable = true;
  };
}
