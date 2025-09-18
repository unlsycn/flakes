{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.programs.hyprshot.enable {
    wayland.windowManager.hyprland.settings.bind =
      with config.wayland.windowManager.hyprland.lib.bindingUtils;
      bindKeys "Control Alt" {
        "A" = "exec, hyprshot -m region --clipboard-only";
        "S" = "exec, hyprshot -m window --clipboard-only";
      };
  };
}
