{
  config,
  lib,
  user,
  ...
}:
with lib;
let
  cfg = config.services.wakatime;
in
{
  options.services.wakatime.enable = mkEnableOption "Wakatime integration for editors";

  config = mkIf cfg.enable {
    persist."/persist".users.${user}.directories = [ ".wakatime" ];

    sops.secrets.wakatime-api_key = {
      sopsFile = ./config.ini;
      format = "ini";
      key = "";
      path = "${config.home.homeDirectory}/.wakatime.cfg";
    };
  };
}
