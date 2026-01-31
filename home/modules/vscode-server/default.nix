{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.services.vscode-server.enable {
    services.vscode-server.installPath = [
      "$HOME/.vscode-server"
      "$HOME/.vscode-server-insiders"
      "$HOME/.antigravity-server"
    ];
    home.persistence."/persist" = {
      directories = [ ".vscode-server" ];
    };
  };
}
