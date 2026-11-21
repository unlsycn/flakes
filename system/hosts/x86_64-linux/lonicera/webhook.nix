{ config, ... }:
{
  # Only GitHub App deliveries are public; the CI UI stays on the mesh.
  mesh.services.webhook = {
    exposure.public = true;
    publicDomain = "webhook.unlsycn.com";
    locations = {
      "= /webhooks/github" = {
        proxyPass = "http://127.0.0.1:${toString config.services.nixbot.port}";
        extraConfig = ''
          client_max_body_size 25m;
          proxy_read_timeout 120s;
        '';
      };
      "/".return = "404";
    };
  };
}
