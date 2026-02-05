{
  config,
  inputs,
  lib,
  user,
  ...
}:
with lib;
{
  imports = [ inputs.buildbot-nix.nixosModules.buildbot-master ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/buildbot"
    ];
  };

  services = {
    buildbot-nix.master = mkIf config.services.buildbot-nix.master.enable {
      domain = "build.unlsycn.com";
      workersFile = config.sops.secrets."buildbot-workers".path;
      authBackend = "github";
      github = {
        topic = "buildbot-unlsycn";
        appId = 2802083;
        oauthId = "Iv23liQ8a05844a479d2";
        appSecretKeyFile = config.sops.secrets."buildbot-github-app-secret-key".path;
        webhookSecretFile = config.sops.secrets."buildbot-github-webhook-secret".path;
        oauthSecretFile = config.sops.secrets."buildbot-github-oauth-secret".path;
      };
      admins = [ user ];
      useHTTPS = true;
    };
    nginx.virtualHosts."${config.services.buildbot-nix.master.domain}" =
      mkIf config.services.nginx.enable
        {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
        };
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
}
