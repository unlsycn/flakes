{
  config,
  inputs,
  pkgs,
  user,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.foundryvtt;
  # https://github.com/nix-foundryvtt/nix-foundryvtt/issues/49
  foundryvttPackage =
    (pkgs.callPackage "${inputs.foundryvtt}/pkgs/foundryvtt" { }).overrideAttrs
      (_: {
        version = "13.0.0+351";
      });
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
      package = mkDefault foundryvttPackage;
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
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.port |> toString}";
        proxyWebsockets = true;
      };
    };
    services.nginx.clientMaxBodySize = "1024m";

    users.users.${user}.extraGroups = [ "foundryvtt" ];

    networking.firewall.allowedTCPPorts = mkIf (!config.services.nginx.enable) [
      cfg.port
    ];
  };
}
