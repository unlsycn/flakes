{ config, lib, ... }:
with lib;
{
  config = mkIf config.services.mihomo.enable {
    services.mihomo.settings = {
      dns = {
        fake-ip-filter = [ "+.shanghaitech.edu.cn" ];
        nameserver-policy = {
          "+.shanghaitech.edu.cn" = [ "dhcp://system" ];
        };
      };
      tun.route-exclude-address = [
        # Campus DNS returns RFC 6598 addresses that must stay on the local network.
        "100.64.0.0/10"
      ];
    };
  };
}
