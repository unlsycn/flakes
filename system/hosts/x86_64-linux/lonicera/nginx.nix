{ config, lib, ... }:
let
  port = 4433;
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "unlsycn@unlsycn.com";
      dnsProvider = "tencentcloud";
      environmentFile = config.sops.secrets.dns-env.path;
    };
  };

  sops.secrets.dns-env = {
    sopsFile = ./dns.env;
    format = "dotenv";
  };

  services = {
    nginx =
      let
        patchPort = {
          listen = [
            {
              addr = "0.0.0.0";
              inherit port;
              ssl = true;
            }
            {
              addr = "[::]";
              inherit port;
              ssl = true;
            }
          ];
          extraConfig = "error_page 497 https://$host:${toString port}$request_uri; ";
        };
      in
      {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        clientMaxBodySize = "1024m";

        virtualHosts = {
          "cache.unlsycn.com" = patchPort;
          "hydra.unlsycn.com" = patchPort // {
            locations."/".extraConfig = ''
              proxy_set_header X-Forwarded-Port ${toString port};
            '';
          };
          "fvtt.unlsycn.com" = patchPort;
          "build.unlsycn.com" = patchPort;
        };
      };
    # patch buildbot-master.buildbotUrl to use the non-standard port
    buildbot-master.buildbotUrl = lib.mkForce "${
      if config.services.buildbot-nix.master.useHTTPS then "https" else "http"
    }://${config.services.buildbot-nix.master.domain}:${toString port}/";
  };

  networking.firewall.allowedTCPPorts = [ port ];

  users.users.nginx.extraGroups = [ "acme" ];
}
