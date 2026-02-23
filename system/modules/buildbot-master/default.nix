{
  config,
  inputs,
  lib,
  ...
}:
with lib;
{
  imports = [ inputs.buildbot-nix.nixosModules.buildbot-master ];

  config = mkIf config.services.buildbot-nix.master.enable {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/buildbot"
      ];
    };

    services.buildbot-nix.master = {
      domain = "build.${config.mesh.nebula.domain}";
      workersFile = config.sops.secrets."buildbot-workers".path;
      authBackend = "github";
      github = {
        topic = "buildbot-unlsycn";
        appId = 2802083;
        oauthId = "Iv23livwH5gqKRzhSokO";
        appSecretKeyFile = config.sops.secrets."buildbot-github-app-secret-key".path;
        webhookSecretFile = config.sops.secrets."buildbot-github-webhook-secret".path;
        oauthSecretFile = config.sops.secrets."buildbot-github-oauth-secret".path;
      };
      admins = [ "unlsycn" ];
      useHTTPS = true;
      webhookBaseUrl = "https://webhook.unlsycn.com/";
    };

    mesh.services.build = {
      internalPort = config.services.buildbot-master.port;
      internalAddress = "127.0.0.1";
      expose = {
        nebula = true;
        tailscale = true;
      };
      extraConfig = ''
        set_real_ip_from ${config.mesh.nebula.cidr};
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;
      '';
    };

    sops.secrets = {
      "buildbot-workers" = {
        sopsFile = ./workers.json;
        # sops --output-type=binary
        format = "binary";
      };
      "buildbot-github-app-secret-key" = {
        sopsFile = ./buildbot.pem;
        format = "binary";
      };
      "buildbot-github-webhook-secret" = {
        sopsFile = ./buildbot.yaml;
      };
      "buildbot-github-oauth-secret" = {
        sopsFile = ./buildbot.yaml;
      };
    };
  };
}
