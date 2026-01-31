{
  config,
  lib,
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

    # TODO: use nix to manager emails without putting cleartext
    home.file.".thunderbird/${config.home.username}/user.js".text = mkForce "";

    home.persistence."/persist" = {
      directories = [ ".thunderbird" ];
    };
  };
}
