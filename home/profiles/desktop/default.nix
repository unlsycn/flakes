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
      msedge = {
        enable = true;
        package = pkgs.microsoft-edge.override {
          commandLineArgs = ''
            --enable-features=TouchpadOverscrollHistoryNavigation \
            --enable-blink-features=MiddleClickAutoscroll'';
        };
      };
      unlauncher.enable = true;
      telegram.enable = true;
      hyprshot.enable = true;
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

    i18n.inputMethod.enabled = "fcitx5";

    wayland.windowManager.hyprland.enable = true;

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
