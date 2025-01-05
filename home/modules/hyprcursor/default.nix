{
  config,
  inputs',
  lib,
  ...
}:
with lib;
{
  # Cannot use mkIf config.home.pointerCursor.hyprcursor.enable as normal, See https://github.com/nix-community/home-manager/blob/master/modules/config/home-cursor.nix
  config = mkIf config.wayland.windowManager.hyprland.enable {
    home.pointerCursor = {
      hyprcursor = {
        enable = true;
        size = 32;
      };
      name = "rose-pine-hyprcursor";
      package = inputs'.rose-pine-hyprcursor.packages.default;
    };
  };
}
