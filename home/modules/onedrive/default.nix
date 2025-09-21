{
  config,
  lib,
  pkgs,
  user,
  ...
}:
with lib;
let
  cfg = config.programs.onedrive;
in
{
  config = mkIf cfg.enable {
    programs.onedrive.settings = {
      sync_dir = "~/OneDrive";
      skip_file = "~*|.~*|*.tmp|*.lock|*.swp|*.partial|*desktop.ini";
    };

    persist."/persist".users.${user} = {
      directories = [
        ".config/onedrive"
        "OneDrive"
      ];
    };

    xdg.configFile = {
      "onedrive/sync_list".source =
        [
          "/Documents"
          "/Pictures"
          "/Music"
        ]
        |> lib.concatStringsSep "\n"
        |> pkgs.writeText "onedrive_sync_list";
    };

    home.file = {
      "Documents".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Documents";
      "Pictures".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Pictures";
    };
  };
}
