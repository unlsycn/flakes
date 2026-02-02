{
  config,
  lib,
  ...
}:
with lib;
{
  options.profile.handheld = {
    enable = mkEnableOption "home-manager profile for handhelds";
  };

  config = mkIf config.profile.handheld.enable {
    programs = {
      alacritty.enable = true;
      zen-browser.enable = true;
    };

    services = {
      blueman-applet.enable = true;
    };

    gtk.enable = true;

    qt = {
      platformTheme = "gnome";
      style.name = "adwaita";
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
    };

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
