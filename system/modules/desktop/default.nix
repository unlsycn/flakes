{ config, lib, ... }:
with lib;
{
  options.hasDesktopEnvironment = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.hasDesktopEnvironment {
    programs.hyprland.enable = true;
  };
}
