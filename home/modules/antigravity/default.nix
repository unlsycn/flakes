{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
let
  catppuccinLib = import "${inputs.catppuccin}/modules/lib" {
    inherit config lib pkgs;
  };
in
{
  config = mkIf (config.programs.antigravity.enable && config.catppuccin.enable) {
    programs.antigravity.profiles = mapAttrs (
      _: profile:
      mkIf profile.enable {
        extensions = [
          (config.catppuccin.sources.vscode.override { catppuccinOptions = profile.settings; })
        ]
        ++ optional profile.icons.enable config.catppuccin.sources.vscode-icons;

        userSettings = mkMerge [
          {
            "workbench.colorTheme" = "Catppuccin " + (catppuccinLib.mkFlavorName profile.flavor);
            "catppuccin.accentColor" = profile.accent;
            "editor.semanticHighlighting.enabled" = mkDefault true;
            "terminal.integrated.minimumContrastRatio" = mkDefault 1;
            "window.titleBarStyle" = mkDefault "custom";
          }

          (mkIf profile.icons.enable {
            "workbench.iconTheme" = "catppuccin-" + profile.icons.flavor;
          })
        ];
      }
    ) config.catppuccin.vscode.profiles;
  };
}
