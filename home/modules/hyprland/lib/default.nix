{ lib, ... }:
with lib;
{
  options.wayland.windowManager.hyprland.lib = mkOption { type = types.attrs; };

  imports = [ ./binding-utils.nix ];
}
