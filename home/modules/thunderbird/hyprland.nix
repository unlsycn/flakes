{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.thunderbird;
  hyprctl = getExe' pkgs.hyprland "hyprctl";
  thunderbird = getExe cfg.package;
in
{
  options.programs.thunderbird.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.startupCommands = [
      thunderbird
      "sleep 5 && ${hyprctl} dispatch 'hl.dsp.window.move({ workspace = \"special:chat\", window = \"class:thunderbird\", follow = false })'"
    ];
  };
}
