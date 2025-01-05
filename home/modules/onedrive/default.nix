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
  options.programs.onedrive = {
    enable = mkEnableOption "OneDrive Client for Linux";
    package = mkPackageOption pkgs "OneDrive" {
      default = [ "onedrive" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    persist."/persist".users.${user} = {
      directories = [
        ".config/onedrive"
        "OneDrive"
      ];
    };

    xdg.configFile = {
      "onedrive/config".source = ./config;
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
