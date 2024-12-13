{
  config,
  lib,
  ...
}:
with lib;
let
  bindingUtils = import ../hyprland/lib/binding-utils.nix { inherit lib; };

  cfg = config.programs.alacritty;
  alacritty = "${cfg.package}/bin/alacritty";
in
with bindingUtils;
{
  options.programs.alacritty.enableHyprlandIntegration = mkOption {
    default = true;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf cfg.enableHyprlandIntegration {
    wayland.windowManager.hyprland.settings.bind = mainBind {
      T = "exec, ${alacritty}";
    };
  };
}
