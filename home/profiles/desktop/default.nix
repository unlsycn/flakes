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
      vscode.enable = true;
      alacritty.enable = true;
      waybar.enable = true;
      msedge.enable = true;
      unlauncher.enable = true;
    };

    services = {
      swaync.enable = true;
      hyprpaper.enable = true;
      cliphist.enable = true;
    };

    home.packages = with pkgs; [
      desktop-scripts
      wl-clipboard
    ];

    wayland.windowManager.hyprland.enable = true;

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
