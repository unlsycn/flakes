{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.ghostty;
  ghosttyNewWindow = "${getExe cfg.package} +new-window";
in
{
  options.programs.ghostty.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland.settings = {
      bind =
        with config.wayland.windowManager.hyprland.lib.bindingUtils;
        main {
          T = dsp.exec ghosttyNewWindow;
        };
      config.misc.swallow_regex = "^(com\\.mitchellh\\.ghostty)$";
    };
  };
}
