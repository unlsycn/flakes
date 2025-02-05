{ config, lib, ... }:
with lib;
{
  config = mkIf config.wayland.windowManager.hyprland.enable {
    # See https://wiki.hyprland.org/Configuring/Environment-variables/
    wayland.windowManager.hyprland.settings.env =
      {
        IN_HYPRLAND = "1";

        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";

        # Wayland
        GDK_BACKEND = "wayland,*";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        # scaling
        GDK_SCALE = "1.5";
        GDK_DPI_SCALE = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_SCALE_FACTOR = "1.75";

        # Themes
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        XCURSOR_SIZE = "36";
      }
      |> mapAttrsToList (name: value: "${name},${value}");
  };
}
