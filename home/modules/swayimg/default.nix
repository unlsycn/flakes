{ config, lib, ... }:
with lib;
{
  imports = [ ./hyprland.nix ];

  config = mkIf config.programs.swayimg.enable {
    programs.swayimg.initLua = ''
      swayimg.imagelist.adjacent = true

      local function bindViewerControls(mode)
        mode.on_key("q", swayimg.exit)
        mode.on_key("j", function() mode.open("next") end)
        mode.on_key("k", function() mode.open("prev") end)

        mode.on_mouse("ScrollUp", function()
          local pos = mode.get_position()
          mode.set_abs_position(pos.x, pos.y + 15)
        end)
        mode.on_mouse("ScrollDown", function()
          local pos = mode.get_position()
          mode.set_abs_position(pos.x, pos.y - 15)
        end)
      end

      local function bindGalleryKey(key, direction)
        swayimg.gallery.on_key(key, function()
          swayimg.gallery.select(direction)
        end)
      end

      bindViewerControls(swayimg.viewer)
      bindViewerControls(swayimg.slideshow)

      swayimg.gallery.on_key("q", swayimg.exit)
      bindGalleryKey("h", "left")
      bindGalleryKey("j", "down")
      bindGalleryKey("k", "up")
      bindGalleryKey("l", "right")
    '';

    xdg.mimeApps.defaultApplicationPackages = [ config.programs.swayimg.package ];
  };
}
