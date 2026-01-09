{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.services.desktopManager.gnome.enable {
    services.gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
      games.enable = false;
      gcr-ssh-agent.enable = false;
    };
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    environment.systemPackages = with pkgs.gnomeExtensions; [
      gjs-osk
      appindicator
      kimpanel
      screen-rotate
      touchup
    ];
  };
}
