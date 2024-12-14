{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  config = mkIf config.services.vscode-server.enable {
    persist."/persist".users.${user} = {
      directories = [ ".vscode-server" ];
    };
  };
}
