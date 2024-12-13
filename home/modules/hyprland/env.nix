{ config, lib, ... }:
with lib;
{
  config = mkIf config.wayland.windowManager.hyprland.enable {
    # See https://wiki.hyprland.org/Configuring/Environment-variables/
    wayland.windowManager.hyprland.settings.env = mapAttrsToList (name: value: "${name},${value}") {
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

      # TODO: Move to Fcitx module
      # ime
      # See https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
      INPUT_METHOD = "fcitx";

      # Hyprcursor
      HYPRCURSOR_SIZE = "48";
      HYPRCURSOR_THEME = "rose-pine-hyprcursor";

      # Themes
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      XCURSOR_SIZE = "36";
    };
  };
}
