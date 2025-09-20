{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.alacritty;
  alacritty = getExe cfg.package;
in
{
  options.programs.alacritty.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.settings = {
      bind =
        with config.wayland.windowManager.hyprland.lib.bindingUtils;
        mainBind {
          T = "exec, ${alacritty}";
        };
      misc.swallow_regex = "(Alacritty)";
    };

  };
}
