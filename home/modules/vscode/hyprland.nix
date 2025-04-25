{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.vscode;
  vscode = "${cfg.package}/bin/code";
in
{
  options.programs.vscode.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf (cfg.enable && cfg.enableHyprlandIntegration) {
    wayland.windowManager.hyprland = with config.wayland.windowManager.hyprland.lib.bindingUtils; {
      settings.bind = mainBind {
        I = "exec, ${vscode}";
      };

      windowRules.class.code = "opacity 0.95";
    };
  };
}
