{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config =
    let
      baseDir = "${config.programs.onedrive.settings.sync_dir}/Music";
    in
    mkIf config.programs.beets.enable {
      assertions = [
        {
          assertion = config.programs.onedrive.enable;
          message = "Please enable OneDrive to sync music library";
        }
      ];

      programs.beets = {
        package =
          with pkgs.python3.pkgs;
          # https://github.com/beetbox/beets/commit/3eb68ef830447d91b10a928823edb3c50cf73f48
          (beets.overrideAttrs {
            src = pkgs.fetchFromGitHub {
              owner = "beetbox";
              repo = "beets";
              rev = "3eb68ef830447d91b10a928823edb3c50cf73f48";
              hash = "sha256-/l7/kFaCoGsUdnU2HR7KzqUt3x/d+PUYwy9iEMIg/7o=";
            };
          }).override
            {
              pluginOverrides = {
                filetote = {
                  enable = true;
                  propagatedBuildInputs = [ beets-filetote ];
                };
              };
            };

        settings = config.sops.templates."beetsConfig".path;
      };

      sops.templates."beetsConfig".content =
        {
          directory = "${baseDir}/Library";
          library = "${baseDir}/library.db";

          plugins = [
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
            max_rec = {
              missing_tracks = "strong";
            };
            distance_weights = {
              missing_tracks = 0.0;
              tracks = 0.5;
            };
          };

          convert = {
            format = "flac";
            formats = {
              flac = "ffmpeg -i $source -y -vn -acodec flac $dest";
            };
          };

          duplicates = {
            full = true;
          };

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
            paths = {
              "paired_ext:.lrc" = "$albumpath/$medianame_new";
            };
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
            source_weight = 0.75;
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

          unimported = {
            ignore_extensions = [
              "jpg"
              "png"
              "lrc"
            ];
          };
        }
        |> pkgs.lib.generators.toYAML { };

      sops.secrets.lastfm_key = {
        sopsFile = ./secrets.yaml;
      };

    };
}
