{ config, ... }:
{
  sops.secrets."buildbot-worker-password" = {
    sopsFile = ./buildbot.yaml;
  };

  services.buildbot-nix.worker.workerPasswordFile =
    config.sops.secrets."buildbot-worker-password".path;
}
