{
  config,
  inputs,
  inputs',
  lib,
  ...
}:
with lib;
let
  cfg = config.services.foundryvtt;
in
{
  imports = [ inputs.foundryvtt.nixosModules.foundryvtt ];
  options.services.foundryvtt = {
    telemetry = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.foundryvtt = {
      package = inputs'.foundryvtt.packages.foundryvtt_13;
      hostName = "fvtt.unlsycn.com";
      port = 1501;
      minifyStaticFiles = true;
      upnp = false;
      language = "cn.foundry_chn";
      telemetry = false;
    };

    services.nginx.virtualHosts."fvtt.unlsycn.com" = mkIf config.services.nginx.enable {
      onlySSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.port |> toString}";
        proxyWebsockets = true;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf (!config.services.nginx.enable) [
      cfg.port
    ];
  };
}
