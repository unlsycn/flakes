{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.services.desktopManager.gnome.enable {
    # GNOME enables Avahi; keep its firewall exposure in the surface model.
    services.avahi.openFirewall = false;
    mesh.surfaces.public.allowedUDPPorts = [ 5353 ];

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
