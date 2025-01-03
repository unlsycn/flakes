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

    wayland.windowManager.hyprland.settings.source = [
      "${pkgs.unlauncher}/usr/share/unlauncher/hyprland.conf"
    ];
  };
}
