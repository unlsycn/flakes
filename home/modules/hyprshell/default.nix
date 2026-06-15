{ config, lib, ... }:
with lib;
let
  cfg = config.services.hyprshell;
  tapMs = 200;
  openOverview = "${getExe cfg.package} socat '\"OpenOverview\"'";
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      services.hyprshell = {
        systemd.args = "--config-file ${config.xdg.configHome}/hyprshell/config.json";

        settings = {
          version = 4;
          windows = {
            overview = {
              modifier = "super";
              key = "XF86Launch9";
              launcher = { };
            };

            switch = {
              modifier = "alt";
              key = "Tab";
              switch_workspaces = true;
              exclude_workspaces = "special:.*";
            };
          };
        };
      };
    }

    (mkIf (cfg.package != null) {
      wayland.windowManager.hyprland.settings.bind =
        with config.wayland.windowManager.hyprland.lib.bindingUtils;
        none {
          control_l = opts { non_consuming = true; } (doubleTap tapMs (dsp.exec openOverview));
        };
    })
  ]);
}
