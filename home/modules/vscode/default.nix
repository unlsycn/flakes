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
        ".wakatime"
      ];

      files = [ ".wakatime.cfg" ];
    };
  };

}
