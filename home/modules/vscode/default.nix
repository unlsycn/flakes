{
  config,
  lib,
  user,
  ...
}:
with lib;
{
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
