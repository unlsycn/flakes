{
  config,
  inputs',
  lib,
  ...
}:
with lib;
{
  options.services.foundryvtt = {
    telemetry = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.services.foundryvtt.enable {
    services.foundryvtt = {
      package = inputs'.foundryvtt.packages.foundryvtt_13;
      hostName = "fvtt.unlsycn.com";
      port = 1501;
      minifyStaticFiles = true;
      upnp = false;
      language = "cn.foundry_chn";
      telemetry = false;
    };

    networking.firewall.allowedTCPPorts = [ config.services.foundryvtt.port ];
  };
}
