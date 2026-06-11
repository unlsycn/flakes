{ lib, ... }:
with lib;
{
  options.wayland.windowManager.hyprland.lib = mkOption { type = types.attrs; };

  imports = [
    ./lua-utils.nix
    ./binding-utils.nix
  ];
}
