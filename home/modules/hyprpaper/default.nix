{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  switchWallpaper = getExe pkgs.switch-wallpaper;
in
{
  config = mkIf config.services.hyprpaper.enable {
    services.hyprpaper.settings = {
      splash = false;
      ipc = true;
    };

    home.packages = [
      (pkgs.makeDesktopItem {
        name = "switch-wallpaper";
        desktopName = "Switch Wallpaper";
        genericName = "Wallpaper Switcher";
        exec = switchWallpaper;
        icon = "preferences-desktop-wallpaper";
        categories = [ "Utility" ];
        keywords = [
          "background"
          "switch_wallpaper"
          "wallpaper"
        ];
        terminal = false;
      })
    ];

    wayland.windowManager.hyprland.startupCommands = [ "sleep 0.5 && ${switchWallpaper}" ];
  };
}
