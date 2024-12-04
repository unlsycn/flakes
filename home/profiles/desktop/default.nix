{ config, lib, ... }:
with lib;
{
  options.profile.desktop = {
    enable = mkEnableOption "home-manager profile for desktop environment";
  };

  config = mkIf config.profile.desktop.enable {

  };
}
