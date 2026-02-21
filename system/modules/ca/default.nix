{ config, lib, ... }:
{
  security = {
    pki.certificateFiles = [ ./root-ca.crt ];
    acme = lib.mkIf config.services.nginx.enable {
      acceptTerms = true;
      defaults = {
        email = "unlsycn@unlsycn.com";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.dns-env.path;
      };
    };
  };

  sops.secrets.dns-env = {
    sopsFile = ./dns.env;
    format = "dotenv";
  };
}
