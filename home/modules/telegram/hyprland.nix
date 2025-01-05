{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.telegram;
  telegram = "${cfg.package}/bin/telegram-desktop";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
in
{
  options.programs.telegram.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf cfg.enableHyprlandIntegration {
    wayland.windowManager.hyprland.settings.exec-once = [
      telegram
      "sleep 5 && ${hyprctl} dispatch closewindow class:org.telegram.desktop"
    ];
  };
}
