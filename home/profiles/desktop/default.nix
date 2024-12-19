{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.profile.desktop = {
    enable = mkEnableOption "home-manager profile for desktop environment";
  };

  config = mkIf config.profile.desktop.enable {
    programs = {
      alacritty.enable = true;
      waybar.enable = true;
    };

    services = {
      swaync.enable = true;
    };

    home.packages = with pkgs; [ desktop-scripts ];

    wayland.windowManager.hyprland.enable = true;
  };
}
