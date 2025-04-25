{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.programs.thunderbird;
in
with lib;
{
  imports = [ ./hyprland.nix ];

  config = mkIf cfg.enable {
    programs.thunderbird.profiles.${config.home.username} = {
      isDefault = true;
    };

    persist."/persist".users.${user} = {
      directories = [ ".thunderbird" ];
    };
  };
}
