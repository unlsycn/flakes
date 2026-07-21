{ config, lib, ... }:
let
  needsAcmeDns01 =
    config.services.nginx.enable
    && (config.services.nginx.virtualHosts |> lib.attrValues |> lib.any (v: v.enableACME));
in
{
  security = {
    pki.certificateFiles = [ ./root-ca.crt ];
    acme = lib.mkIf needsAcmeDns01 {
      acceptTerms = true;
      defaults = {
        email = "unlsycn@unlsycn.com";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.dns-env.path;
      };
    };
  };

  sops.secrets.dns-env = lib.mkIf needsAcmeDns01 {
    sopsFile = ./dns.env;
    format = "dotenv";
  };
}
