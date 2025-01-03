{
  config,
  lib,
  ...
}:
with lib;
let
  bindingUtils = import ../hyprland/lib/binding-utils.nix { inherit lib; };

  cfg = config.programs.msedge;
  msedge = "${cfg.package}/bin/microsoft-edge";
in
with bindingUtils;
{
  options.programs.msedge.enableHyprlandIntegration = mkOption {
    default = true;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf cfg.enableHyprlandIntegration {
    wayland.windowManager.hyprland.settings.bind = mainBind {
      W = "exec, ${msedge}";
    };
  };
}
