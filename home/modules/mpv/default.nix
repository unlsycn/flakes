{ config, lib, ... }:
with lib;
{
  config = mkIf config.programs.mpv.enable {
    programs.mpv = {
      defaultProfiles = [ "high-quality" ];

      config = {
        cscale = "catmull_rom";
        deband = true;
        hwdec = "auto";
        video-sync = "display-resample";
        video-sync-max-factor = 7;
        interpolation = true;
        tscale = "oversample";
        sub-auto = "fuzzy";
        autocreate-playlist = "same";
        directory-mode = "ignore";
        save-position-on-quit = true;
        watch-later-options = "start";
        screenshot-dir = "${config.xdg.userDirs.pictures}/Screenshots/mpv";
        screenshot-format = "png";
        osd-on-seek = "msg-bar";
        replaygain = "track";
      };
    };

    xdg.mimeApps.defaultApplicationPackages = [ config.programs.mpv.finalPackage ];
  };
}
