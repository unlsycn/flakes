{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.zen-browser;
  zen = getExe cfg.package;
in
{
  options.programs.zen-browser.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.settings.bind =
      with config.wayland.windowManager.hyprland.lib.bindingUtils;
      mainBind {
        W = "exec, ${zen}";
      };
  };
}
