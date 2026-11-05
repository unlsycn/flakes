{ config, lib, ... }:
with lib;
let
  cfg = config.wayland.windowManager.hyprland;
  enabled = monitor: builtins.elem monitor cfg.monitors;
in
{
  options.wayland.windowManager.hyprland.monitors = mkOption {
    type =
      with types;
      listOf (enum [
        "allay"
        "philips"
      ]);
    default = [ "allay" ];
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.monitor =
      optional (enabled "allay") {
        output = "eDP-1";
        mode = "2880x1800@120";
        position = "0x0";
        scale = 1.8;
      }
      ++ optional (enabled "philips") {
        output = "desc:Philips Consumer Electronics Company PHL24M1N5500Z";
        mode = "highrr";
        position = "0x-1152";
        scale = 1.25;
      };
  };
}
