{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.telegram;
  telegram = getExe cfg.package;
  hyprctl = getExe' pkgs.hyprland "hyprctl";
in
{
  options.programs.telegram.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.startupCommands = [
      telegram
      "sleep 5 && ${hyprctl} dispatch 'hl.dsp.window.close({ window = \"class:org.telegram.desktop\" })'"
    ];
  };
}
