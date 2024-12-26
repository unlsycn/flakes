{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  imports = [ ./hyprland.nix ];

  config = mkIf config.programs.vscode.enable {
    persist."/persist".users.${user} = {
      directories = [
        ".config/Code"
        ".vscode"
        ".wakatime"
      ];

      files = [ ".wakatime.cfg" ];
    };
  };

}
