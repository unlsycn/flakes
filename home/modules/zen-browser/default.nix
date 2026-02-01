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

    home.persistence."/persist" = {
      directories = [ ".zen" ];
    };
  };
}
