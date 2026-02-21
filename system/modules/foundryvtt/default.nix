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
      hostName = "fvtt.${config.mesh.tailnet.domain}";
      port = 1501;
      minifyStaticFiles = true;
      upnp = false;
      language = "cn.foundry_chn";
      telemetry = false;
    };

    mesh.services.fvtt = {
      expose = {
        nebula = true;
        tailscale = true;
        public = true;
      };
      publicDomain = "fvtt.unlsycn.com";
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
