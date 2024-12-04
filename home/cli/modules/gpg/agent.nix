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
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
}
