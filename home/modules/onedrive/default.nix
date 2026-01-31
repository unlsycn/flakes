{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.onedrive;
  syncDir = "OneDrive";
in
{
  options.programs.onedrive.persist = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf cfg.enable {
    programs.onedrive.settings = {
      sync_dir = "~/${syncDir}";
      skip_file = "~*|.~*|*.tmp|*.lock|*.swp|*.partial|*desktop.ini";
    };

    home.persistence."/persist" = {
      directories = [
        ".config/onedrive"
      ]
      ++ optional cfg.persist syncDir;
    };

    xdg.configFile = {
      "onedrive/sync_list".text =
        [
          "/Documents"
          "/Pictures"
          "/Music"
          "/文档"
          "/应用"
        ]
        |> lib.concatStringsSep "\n";
    };

    home.file = {
      "Documents".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Documents";
      "Pictures".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Pictures";
    };
  };
}
