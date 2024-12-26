{
  config,
  lib,
  ...
}:
with lib;
let
  bindingUtils = import ../hyprland/lib/binding-utils.nix { inherit lib; };

  cfg = config.programs.vscode;
  vscode = "${cfg.package}/bin/code";
in
with bindingUtils;
{
  options.programs.vscode.enableHyprlandIntegration = mkOption {
    default = true;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf cfg.enableHyprlandIntegration {
    wayland.windowManager.hyprland.settings = {
      bind = mainBind {
        I = "exec, ${vscode}";
      };

      windowrulev2 = [ "opacity 0.95, class:code" ];
    };
  };
}
