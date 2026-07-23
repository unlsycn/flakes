{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.zen-browser;
in
with lib;
{
  imports = [ ./hyprland.nix ];

  config = mkIf cfg.enable {
    programs.zen-browser.policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
    };

    xdg.mimeApps.defaultApplicationPackages = [ cfg.finalPackage ];

    home.persistence."/persist" = {
      directories = [ ".zen" ];
    };
  };
}
