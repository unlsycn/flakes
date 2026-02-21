{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.buildbot-nix.nixosModules.buildbot-worker ];

  config = lib.mkIf config.services.buildbot-nix.worker.enable {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/buildbot-worker"
      ];
    };
  };
}
