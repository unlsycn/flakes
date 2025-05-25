{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.profile.desktop = {
    enable = mkEnableOption "home-manager profile for desktop environment";
  };

  config = mkIf config.profile.desktop.enable {
    programs = {
      vscode.enable = true;
      alacritty.enable = true;
      waybar.enable = true;
      zen-browser.enable = true;
      unlauncher.enable = true;
      telegram.enable = true;
      hyprshot.enable = true;
      zotero.enable = true;
      obsidian.enable = true;
      thunderbird.enable = true;
    };

    services = {
      swaync.enable = true;
      hyprpaper.enable = true;
      cliphist.enable = true;
      hypridle.enable = true;
      blueman-applet.enable = true;
    };

    home.packages = with pkgs; [
      desktop-scripts
      wl-clipboard
    ];

    gtk.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
    };

    wayland.windowManager.hyprland.enable = true;

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
