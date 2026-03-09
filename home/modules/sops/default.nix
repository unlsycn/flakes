{
  config,
  lib,
  ...
}:
with lib;
{
  options.sops.control = {
    deploySecrets = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to deploy sops secrets";
    };
    deploySshSecrets = mkOption {
      type = types.bool;
      default = false;
    };
    deployPrivateFiles = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    sops.age.keyFile = "${config.xdg.configHome}/age/key";

    # sops require gnupg passphrase
    systemd.user.services.sops-nix.Service = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
