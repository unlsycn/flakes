{ config, lib, ... }:
with lib;
let
  cfg = config.programs.swayimg;
in
{
  options.programs.swayimg.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.windowRules.swayimg = {
      match.class = "swayimg";
      center = true;
      float = true;
    };
  };
}
