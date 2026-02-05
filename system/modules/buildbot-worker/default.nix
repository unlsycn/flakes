{
  inputs,
  ...
}:
{
  imports = [ inputs.buildbot-nix.nixosModules.buildbot-worker ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/buildbot-worker"
    ];
  };
}
