{
  config,
  lib,
  inputs,
  system,
  ...
}:
{
  config = lib.mkIf config.programs.hyprland.enable {
    programs.hyprland = {
      package = inputs.hyprland.packages.${system}.hyprland;
      portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    };
  };
}
