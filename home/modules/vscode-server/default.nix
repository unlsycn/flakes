{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.services.vscode-server.enable {
    home.persistence."/persist" = {
      directories = [ ".vscode-server" ];
    };
  };
}
