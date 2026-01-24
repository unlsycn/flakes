{
  config,
  lib,
  pkgs,
  user,
  ...
}:
with lib;
let
  cfg = config.programs.vscode;
in
{
  imports = [ ./hyprland.nix ];

  options.programs.vscode = {
    continue.enable = mkEnableOption "Continue extension for VSCode";
    useAntigravity = mkOption {
      type = types.bool;
      default = false;
      description = "Use Antigravity instead of VSCode";
    };
  };

  config = mkIf cfg.enable {
    persist."/persist".users.${user}.directories = [
      cfg.dataFolderName
      ".config/${cfg.nameShort}"
    ]
    ++ optional cfg.continue.enable ".continue";

    programs.vscode.package =
      let
        basePackage = if cfg.useAntigravity then pkgs.antigravity else pkgs.vscode;
        overrideForContinue =
          pkg:
          pkg.overrideAttrs (
            final: prev: {
              preFixup =
                prev.preFixup
                + "gappsWrapperArgs+=( --prefix LD_LIBRARY_PATH : ${makeLibraryPath [ pkgs.gcc.cc.lib ]} )";
            }
          );
      in
      if cfg.continue.enable then basePackage |> overrideForContinue else basePackage;

    services.wakatime.enable = true;
  };
}
