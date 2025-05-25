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
      skip_file = "~*|.~*|*.tmp|*.lock|*desktop.ini";
    };

    persist."/persist".users.${user} = {
      directories = [
        ".config/onedrive"
        "OneDrive"
      ];
    };

    xdg.configFile = {
      "onedrive/sync_list".source = ./sync_list;
    };

    sops.secrets.onedrive-refresh_token = {
      sopsFile = ./refresh_token.yaml.admin;
      path = "${config.xdg.configHome}/onedrive/refresh_token";
    };

    home.file = {
      "Documents".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Documents";
      "Pictures".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Pictures";
    };
  };
}
