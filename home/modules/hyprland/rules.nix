{ config, lib, ... }:
with lib;
{
  config = mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland.settings = { };
  };
}
