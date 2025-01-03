{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  switch_wallpaper = "${pkgs.desktop-scripts}/bin/switch_wallpaper";
in
{
  config = mkIf config.services.hyprpaper.enable {
    services.hyprpaper.settings.ipc = "on";

    wayland.windowManager.hyprland.settings.exec-once = [ "sleep 0.5 && ${switch_wallpaper}" ];
  };
}
