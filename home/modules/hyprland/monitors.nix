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
      ++ optionals (enabled "philips") [
        {
          output = "DP-1";
          mode = "2560x1440@165";
          position = "0x-1152";
          scale = 1.25;
        }
        {
          output = "HDMI-A-1";
          mode = "2560x1440@144";
          position = "0x-1152";
          scale = 1.25;
        }
      ];
  };
}
