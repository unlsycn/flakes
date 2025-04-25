{
  config,
  lib,
  user,
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

    persist."/persist".users.${user} = {
      directories = [ ".zen" ];
    };
  };
}
