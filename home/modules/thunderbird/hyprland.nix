{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.thunderbird;
  thunderbird = getExe cfg.package;
in
{
  options.programs.thunderbird.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.settings.exec-once = [
      thunderbird
      "sleep 5 && hyprctl dispatch movetoworkspacesilent special:chat,class:thunderbird"
    ];
  };
}
