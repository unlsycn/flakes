{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hyprshot;
in
with lib;
{
  options.programs.hyprshot = {
    enable = mkEnableOption "An utility to easily take screenshots in Hyprland using your mouse";
    package = mkPackageOption pkgs "Hyprshot" {
      default = [ "hyprshot" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    wayland.windowManager.hyprland.settings.bind =
      with config.wayland.windowManager.hyprland.lib.bindingUtils;
      bindKeys "Control Alt" {
        "A" = "exec, hyprshot -m region --clipboard-only";
        "S" = "exec, hyprshot -m window --clipboard-only";
      };
  };
}
