{
  config,
  lib,
  ...
}:
with lib;
{
  options = {
    hasDesktopEnvironment = mkOption {
      type = types.bool;
      default = config.handheld.enable;
    };
  };

  config = mkMerge [
    (mkIf (config.hasDesktopEnvironment && !config.handheld.enable) {
      programs.hyprland.enable = mkDefault true;
    })
    (mkIf config.handheld.enable {
      services.desktopManager.gnome.enable = true;
    })
  ];
}
