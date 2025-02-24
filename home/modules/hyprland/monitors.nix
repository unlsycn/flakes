{ config, lib, ... }:
with lib;
let
  cfg = config.wayland.windowManager.hyprland;
  forMonitor = monitor: rule: optionalString (builtins.elem monitor cfg.monitors) rule;
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
    wayland.windowManager.hyprland.settings.monitor = [
      (forMonitor "allay" "eDP-1, 2880x1800@120, 0x0, 1.8")
      (forMonitor "philips" "DP-1, 2560x1440@165, 0x-1152, 1.25")
      (forMonitor "philips" "HDMI-A-1, 2560x1440@120, 0x-1152, 1.25")
    ];
  };
}
