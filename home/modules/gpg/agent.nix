{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.services.gpg-agent.enable {
    services.gpg-agent = {
      enableExtraSocket = true;
      pinentryPackage = if config.profile.desktop.enable then pkgs.pinentry-qt else pkgs.pinentry-tty;
    };
  };
}
