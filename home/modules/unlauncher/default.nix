{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.unlauncher;
  tapDelay = "0.2";
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
      settings.bind =
        with config.wayland.windowManager.hyprland.lib.bindingUtils;
        none {
          control_l = many [
            (opts { non_consuming = true; } (
              dsp.exec "sleep ${tapDelay} && hyprctl dispatch 'hl.dsp.submap(\"reset\")'"
            ))
            (opts { non_consuming = true; } (dsp.submap "launcher"))
          ];
        };

      submaps.launcher.settings.bind =
        with config.wayland.windowManager.hyprland.lib.bindingUtils;
        none {
          control_l = many [
            (dsp.exec "${cfg.package}/bin/unlauncher")
            (dsp.submap "reset")
          ];
        };

      windowRules.unlauncher = {
        match = {
          title = "Unlauncher";
          initial_title = "Unlauncher";
        };
        center = true;
        float = true;
        size = "monitor_w*0.4 monitor_h*0.3";
      };
    };
  };
}
