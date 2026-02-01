{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.wakatime;
in
{
  options.services.wakatime.enable = mkEnableOption "Wakatime integration for editors";

  config = mkIf cfg.enable {
    home.persistence."/persist".directories = [ ".wakatime" ];

    sops.secrets.wakatime-api_key = {
      sopsFile = ./config.ini;
      format = "ini";
      key = "";
      path = "${config.home.homeDirectory}/.wakatime.cfg";
    };
  };
}
