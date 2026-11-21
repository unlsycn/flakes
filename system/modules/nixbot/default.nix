{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.nixbot;
in
{
  imports = [ inputs.nixbot.nixosModules.nixbot ];

  config = mkIf cfg.enable {
    services.nixbot = {
      domain = config.mesh.services.build.domain;
      admins = [ "github:unlsycn" ];
      statusContextPrefix = "nixbot";
      useHTTPS = true;
      webhookBaseUrl = "https://webhook.unlsycn.com/";
      nginx.enable = false;
      github = {
        enable = true;
        # Bootstrap existing projects once; subsequent enablement lives in the database.
        topic = "buildbot-unlsycn";
        appId = 2802083;
        oauthId = "Iv23livwH5gqKRzhSokO";
        appSecretKeyFile = config.sops.secrets."nixbot-github-app-secret-key".path;
        webhookSecretFile = config.sops.secrets."nixbot-github-webhook-secret".path;
        oauthSecretFile = config.sops.secrets."nixbot-github-oauth-secret".path;
      };
    };

    # With upstream nginx disabled the socket defaults to a wildcard TCP listener.
    systemd.sockets.nixbot.socketConfig.ListenStream = mkForce "127.0.0.1:${toString cfg.port}";

    environment.persistence."/persist".directories = [
      {
        directory = "/var/lib/nixbot";
        user = "nixbot";
        group = "nixbot";
        mode = "0700";
      }
    ];

    mesh.services.build = {
      singleDomain = true;
      internalPort = cfg.port;
      internalAddress = "127.0.0.1";
      exposure = {
        nebula = true;
        tailnet = true;
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          client_max_body_size 25m;
          proxy_connect_timeout 120s;
          proxy_send_timeout 120s;
          proxy_read_timeout 3600s;
          proxy_buffering off;
        '';
      };
      extraConfig = ''
        set_real_ip_from ${config.mesh.nebula.cidr};
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;
      '';
    };

    sops.secrets = {
      "nixbot-github-app-secret-key" = {
        sopsFile = ./github-app.pem;
        format = "binary";
      };
      "nixbot-github-webhook-secret".sopsFile = ./nixbot.yaml;
      "nixbot-github-oauth-secret".sopsFile = ./nixbot.yaml;
    };
  };
}
