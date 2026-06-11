{ config, lib, ... }:
with lib;
let
  cfg = config.wayland.windowManager.hyprland;
  lua = cfg.lib.luaUtils;
in
{
  options.wayland.windowManager.hyprland.startupCommands = mkOption {
    type = with types; listOf str;
    default = [ ];
    description = "Commands to execute on Hyprland startup.";
  };

  config = mkIf (cfg.enable && cfg.startupCommands != [ ]) {
    wayland.windowManager.hyprland.extraConfig = lua.startupHook cfg.startupCommands;
  };
}
