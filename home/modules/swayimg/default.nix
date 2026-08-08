{ config, lib, ... }:
with lib;
{
  imports = [ ./hyprland.nix ];

  config = mkIf config.programs.swayimg.enable {
    programs.swayimg.initLua = ''
      swayimg.imagelist.adjacent = true

      local function bindViewerKeys(mode)
        mode.on_key("q", swayimg.exit)
        mode.on_key("j", function() mode.open("next") end)
        mode.on_key("k", function() mode.open("prev") end)
      end

      local function bindGalleryKey(key, direction)
        swayimg.gallery.on_key(key, function()
          swayimg.gallery.select(direction)
        end)
      end

      bindViewerKeys(swayimg.viewer)
      bindViewerKeys(swayimg.slideshow)

      swayimg.gallery.on_key("q", swayimg.exit)
      bindGalleryKey("h", "left")
      bindGalleryKey("j", "down")
      bindGalleryKey("k", "up")
      bindGalleryKey("l", "right")
    '';

    xdg.mimeApps.defaultApplicationPackages = [ config.programs.swayimg.package ];
  };
}
