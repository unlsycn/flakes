{
  config,
  lib,
  ...
}:
with lib;
let
  editors = {
    vscode = {
      name = "Visual Studio Code";
      cfg = config.programs.vscode;
    };
    antigravity = {
      name = "Antigravity";
      cfg = config.programs.antigravity;
    };
  };

  editorEnabled = editor: editor.cfg.enable && editor.cfg.enableHyprlandIntegration;
  enabledEditors = filterAttrs (_: editorEnabled) editors;
  primaryEditor = if editorEnabled editors.antigravity then editors.antigravity else editors.vscode;

  mkOpacityRule = editor: {
    match.class = editor.cfg.package.meta.mainProgram;
    opacity = "0.95";
  };
in
{
  options.programs = mapAttrs (_: editor: {
    enableHyprlandIntegration = mkOption {
      default = config.wayland.windowManager.hyprland.enable;
      type = types.bool;
      description = "Whether to enable Hyprland integration for ${editor.name}";
    };
  }) editors;

  config = mkIf (enabledEditors != { }) {
    wayland.windowManager.hyprland = with config.wayland.windowManager.hyprland.lib.bindingUtils; {
      settings.bind = main {
        I = dsp.exec (getExe primaryEditor.cfg.package);
      };

      windowRules = mapAttrs' (
        name: editor: nameValuePair "${name}-opacity" (mkOpacityRule editor)
      ) enabledEditors;
    };
  };
}
