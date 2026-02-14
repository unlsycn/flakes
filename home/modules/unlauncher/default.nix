{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.unlauncher;
in
{
  options.programs.unlauncher = {
    enable = mkEnableOption "A 30-line app launcher based on fzf";
    package = mkPackageOption pkgs "unlauncher" {
      default = [ "unlauncher" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    wayland.windowManager.hyprland = {
      extraConfig = ''
        bindn = , control_l, exec, sleep 0.2 && hyprctl dispatch submap reset
        bindn = , control_l, submap, launcher
        submap = launcher
        bind = , control_l, exec, ${cfg.package}/bin/unlauncher
        bind = , control_l, submap, reset
        submap = reset
      '';

      windowRules.unlauncher = {
        props = [
          {
            type = "title";
            value = "Unlauncher";
          }
          {
            type = "initial_title";
            value = "Unlauncher";
          }
        ];
        effects = [
          {
            type = "center";
            value = "true";
          }
          {
            type = "float";
            value = "true";
          }
          {
            type = "size";
            value = "monitor_w*0.4 monitor_h*0.3";
          }
        ];
      };
    };
  };
}
