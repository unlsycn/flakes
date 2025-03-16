{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hyprshot;
  bindingUtils = import ../hyprland/lib/binding-utils.nix { inherit lib; };
in
with lib;
with bindingUtils;
{
  options.programs.hyprshot = {
    enable = mkEnableOption "An utility to easily take screenshots in Hyprland using your mouse";
    package = mkPackageOption pkgs "Hyprshot" {
      default = [ "hyprshot" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    wayland.windowManager.hyprland.settings.bind = bindKeys "Control Alt" {
      "A" = "exec, hyprshot -m region --clipboard-only";
      "S" = "exec, hyprshot -m window --clipboard-only";
    };
  };
}
