{ config, lib, ... }:
with lib;
{
  config = mkIf config.services.resolved.enable {
    services.mihomo.settings.tun.route-exclude-address = [
      "127.0.0.53/32"
    ];
  };
}
