{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.zotero;
in
{
  options.programs.zotero.enableHyprlandIntegration = mkOption {
    default = config.wayland.windowManager.hyprland.enable;
    type = types.bool;
    description = "Whether to enable Hyprland integration";
  };

  config = mkIf cfg.enableHyprlandIntegration {
    windowRules.custom."class:(Zotero), title:^(Progress)$" = [
      "float"
      "size 20% 10%"
      "move 80% 90%"
    ];
  };
}
