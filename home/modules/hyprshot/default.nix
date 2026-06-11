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
      ctrlAlt {
        "A" = dsp.exec "hyprshot -m region --clipboard-only";
        "S" = dsp.exec "hyprshot -m window --clipboard-only";
      };
  };
}
