{ lib, ... }:
with lib;
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking = {
    useNetworkd = true;
    networkmanager.enable = true;
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    firewall.enable = mkDefault true;
  };

  services = {
    mihomo.enable = mkDefault true;
    blueman.enable = true;
  };
}
