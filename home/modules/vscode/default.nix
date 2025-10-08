{
  config,
  lib,
  pkgs,
  user,
  ...
}:
with lib;
{
  imports = [ ./hyprland.nix ];

  options.programs.vscode.continue = {
    enable = mkEnableOption "Continue extension for VSCode";
  };

  config = mkIf config.programs.vscode.enable {
    persist."/persist".users.${user}.directories = [
      ".config/Code"
      ".vscode"
    ]
    ++ optional config.programs.vscode.continue.enable ".continue";

    programs.vscode.package =
      if config.programs.vscode.continue.enable then
        # https://github.com/continuedev/continue/issues/821#issuecomment-3227673526
        (pkgs.vscode.overrideAttrs (
          final: prev: {
            preFixup =
              prev.preFixup
              + "gappsWrapperArgs+=( --prefix LD_LIBRARY_PATH : ${makeLibraryPath [ pkgs.gcc.cc.lib ]} )";
          }
        ))
      else
        pkgs.vscode;

    services.wakatime.enable = true;
    programs.vscode.continue.enable = true;
  };
}
