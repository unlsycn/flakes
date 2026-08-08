{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  homeDirectory = config.home.homeDirectory;
in
{
  options.profile.desktop = {
    enable = mkEnableOption "home-manager profile for desktop environment";
  };

  config = mkIf config.profile.desktop.enable {
    programs = {
      swayimg.enable = true;
      vscode.enable = true;
      ghostty.enable = true;
      waybar.enable = true;
      zen-browser.enable = true;
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
      hyprshell.enable = true;
      blueman-applet.enable = true;
    };

    home.packages = with pkgs; [
      wl-clipboard
    ];

    gtk.enable = true;
    dconf.enable = false;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
    };

    wayland.windowManager.hyprland.enable = true;

    xdg = {
      userDirs = {
        enable = true;
        createDirectories = false;
        setSessionVariables = false;

        documents = "${homeDirectory}/Documents";
        download = "${homeDirectory}/Downloads";
        music = "${homeDirectory}/Music";
        pictures = "${homeDirectory}/Pictures";
        projects = "${homeDirectory}/Workspaces";
        videos = "${homeDirectory}/Videos";
        desktop = null;
        publicShare = null;
        templates = null;
      };

      mimeApps.enable = true;
    };

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
