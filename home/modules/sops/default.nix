{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [ ./admin.nix ];
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

  config = mkMerge [
    {
      sops.age.keyFile = "${config.xdg.configHome}/age/key";

      systemd.user.services.sops-nix = {
        Unit = {
          StartLimitIntervalSec = 300;
          StartLimitBurst = 5;
        };
        Service = {
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    }
    (mkIf config.services.gpg-agent.enable {
      sops.gnupg.home = mkDefault "${config.home.homeDirectory}/.gnupg";
    })
  ];
}
