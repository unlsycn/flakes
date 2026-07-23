{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.beets;
  baseDir = config.xdg.userDirs.music;
  enabledPlugins = [
    "badfiles"
    "convert"
    "duplicates"
    "edit"
    "embedart"
    "export"
    "fetchart"
    "filetote"
    "filefilter"
    "fromfilename"
    "fuzzy"
    "info"
    "mbsync"
    "missing"
    "replaygain"
    "smartplaylist"
    "spotify"
    "playlist"
    "types"
    "unimported"
    "zero"
  ];
in
{
  config = mkIf cfg.enable {
    programs.beets.package = pkgs.python3.pkgs.beets.override {
      disableAllPlugins = true;
      pluginOverrides = genAttrs enabledPlugins (
        plugin:
        {
          enable = true;
        }
        // optionalAttrs (plugin == "filetote") {
          propagatedBuildInputs = [
            (pkgs.python3.pkgs.beets-filetote.overrideAttrs {
              # FIXME https://github.com/astral-sh/uv/issues/15000
              doInstallCheck = false;
              nativeInstallCheckInputs = [ ];
            })
          ];
        }
      );
    };

    xdg.configFile."beets/config.yaml".source = mkForce (
      config.lib.file.mkOutOfStoreSymlink config.sops.templates.beetsConfig.path
    );

    sops = {
      secrets.lastfm_key.sopsFile = ./secrets.yaml;
      templates.beetsConfig.content =
        {
          directory = "${baseDir}/Library";
          library = "${baseDir}/library.db";

          plugins = enabledPlugins;

          import = {
            write = true;
            copy = true;
            duplicate_verbose_prompt = true;
          };

          paths = {
            default = "$albumartist/$album%aunique{}/$track $title";
            singleton = "$artist/$title";
            comp = "Compilations/$album%aunique{}/$track $title";
          };

          match = {
            max_rec.missing_tracks = "strong";
            distance_weights = {
              missing_tracks = 0.0;
              tracks = 0.5;
            };
          };

          convert = {
            format = "flac";
            formats.flac = "ffmpeg -i $source -y -vn -acodec flac $dest";
          };

          duplicates.full = true;

          embedart = {
            auto = true;
            ifempty = true;
          };

          fetchart = {
            sources = [
              "filesystem"
              "coverart"
              "itunes"
              "amazon"
              "albumart"
              "lastfm"
            ];
            lastfm_key = config.sops.placeholder.lastfm_key;
          };

          filetote = {
            pairing = {
              enabled = true;
              extensions = ".lrc";
            };
            paths."paired_ext:.lrc" = "$albumpath/$medianame_new";
          };

          replaygain = {
            overwrite = true;
            backend = "ffmpeg";
            r128 = [
              "opus"
              "flac"
              "mp3"
              "ogg"
              "wav"
              "m4a"
              "webm"
            ];
            r128_targetlevel = 84;
          };

          spotify = {
            data_source_mismatch_penalty = 0.75;
            show_failures = true;
          };

          playlist = {
            auto = true;
            playlist_dir = baseDir;
            relative_to = "playlist";
          };

          zero = {
            auto = false;
            fields = "lyrics";
            update_database = true;
          };

          unimported.ignore_extensions = [
            "jpg"
            "png"
            "lrc"
          ];
        }
        |> pkgs.lib.generators.toYAML { };
    };
  };
}
