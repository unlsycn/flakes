{
  lib,
  inputs,
  system,
  ...
}:
with lib;
with builtins;
let
  packageList = attrNames (filterAttrs (name: type: type == "directory") (readDir ./.));
in
{
  nixpkgs.overlays = [
    (self: super: genAttrs packageList (name: self.callPackage ./${name} { }))
    (final: prev: {
      # will cause local compliation of packages that depend on Hyprland
      hyprland = inputs.hyprland.packages.${system}.hyprland;
      xdg-desktop-portal-hyprland = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    })
  ];
}
