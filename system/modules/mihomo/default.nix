{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.services.mihomo.enable {
    services.mihomo = {
      tunMode = true;
      webui = pkgs.metacubexd;
      configFile = config.sops.secrets.mihomoConfig.path;
    };

    sops.secrets.mihomoConfig = {
      sopsFile = ./config.yaml;
      key = "";
    };

  };
}
