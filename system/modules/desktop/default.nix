{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  options.hasDesktopEnvironment = mkOption {
    type = types.bool;
    default = config.isHandheld;
  };
  options.isHandheld = mkOption {
    type = types.bool;
    default = false;
  };

  config =
    mkIf (config.hasDesktopEnvironment && !config.isHandheld) {
      programs.hyprland.enable = mkDefault true;
    }
    // mkIf config.isHandheld {
      services.desktopManager.gnome.enable = true;
      services.handheld-daemon = {
        # does not work with inputplumber and causes RGB not to be turned off
        enable = false;
        user = user;
        ui.enable = true;
      };
    };
}
