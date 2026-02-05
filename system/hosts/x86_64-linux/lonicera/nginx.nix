{ config, lib, ... }:
with lib;
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
    format = "binary";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "1024m";

    virtualHosts = {
      "cache.unlsycn.com" = mkIf config.services.harmonia-dev.cache.enable {
        listen = [
          {
            addr = "0.0.0.0";
            port = port;
            ssl = true;
          }
          {
            addr = "[::]";
            port = port;
            ssl = true;
          }
        ];
        enableACME = true;
        onlySSL = true;
        acmeRoot = null;
        locations."/".proxyPass = "http://127.0.0.1:${config.services.harmonia-dev.port |> toString}";
      };

      "hydra.unlsycn.com" = mkIf config.services.hydra.enable {
        listen = [
          {
            addr = "0.0.0.0";
            port = port;
            ssl = true;
          }
          {
            addr = "[::]";
            port = port;
            ssl = true;
          }
        ];
        enableACME = true;
        onlySSL = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${config.services.hydra.port |> toString}";
          extraConfig = ''
            proxy_set_header X-Forwarded-Port ${toString port};
          '';

        };
      };

      "fvtt.unlsycn.com" = mkIf config.services.foundryvtt.enable {
        listen = [
          {
            addr = "0.0.0.0";
            port = port;
            ssl = true;
          }
          {
            addr = "[::]";
            port = port;
            ssl = true;
          }
        ];
        enableACME = true;
        onlySSL = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${config.services.foundryvtt.port |> toString}";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

  users.users.nginx.extraGroups = [ "acme" ];
}
