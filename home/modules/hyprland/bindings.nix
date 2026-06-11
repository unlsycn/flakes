{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins;
let
  switch_workspace = "${pkgs.desktop-scripts}/bin/switch_workspace";
  volume = "${pkgs.desktop-scripts}/bin/volume";
  workspaceKeys = genAttrs (10 |> genList (x: toString x)) (key: if key == "0" then "10" else key);
  vimDirections = {
    H = "l";
    L = "r";
    K = "u";
    J = "d";
  };
  arrowDirections = {
    Left = "l";
    Right = "r";
    Up = "u";
    Down = "d";
  };
  specialWorkspaces = {
    F = "code";
    C = "chat";
    R = "remote";
  };
in
{
  config = mkIf config.wayland.windowManager.hyprland.enable {
    # See https://wiki.hyprland.org/Configuring/Keywords/
    wayland.windowManager.hyprland.settings =
      with config.wayland.windowManager.hyprland.lib.bindingUtils; {
        bind =
          main (
            {
              X = dsp.window.close;
              P = dsp.window.toggleFloating;
              B = dsp.layout "togglesplit"; # dwindle
              E = dsp.layout "swapwithmaster"; # master
              A = dsp.window.maximize;

              mouse_down = dsp.exec "${switch_workspace} -p";
              mouse_up = dsp.exec "${switch_workspace}";
              "mouse:272" = opts { mouse = true; } dsp.window.drag;
              "mouse:273" = opts { mouse = true; } dsp.window.resize;
            }
            // mapActions dsp.focus vimDirections
            // mapActions dsp.window.move arrowDirections
            // mapActions dsp.workspace.focus workspaceKeys
            // mapActions dsp.workspace.toggleSpecial specialWorkspaces
            // mapActions (ratio: opts { repeating = true; } (dsp.layout "splitratio ${ratio}")) {
              Minus = "-0.1";
              Equal = "+0.1";
              Semicolon = "-0.1";
              Apostrophe = "+0.1";
            }
          )
          ++ mainShift (
            {
              mouse_down = dsp.exec "${switch_workspace} -pm";
              mouse_up = dsp.exec "${switch_workspace} -m";
            }
            // mapActions dsp.window.move vimDirections
            // mapActions dsp.window.moveToWorkspace workspaceKeys
            // mapActions (workspace: dsp.window.moveToWorkspace "special:${workspace}") specialWorkspaces
          )
          ++ alt {
            Tab = dsp.exec "${switch_workspace}";
          }
          ++ altShift {
            Tab = dsp.exec "${switch_workspace} -p";
          }
          ++ none (
            mapActions
              (
                command:
                opts {
                  locked = true;
                  repeating = true;
                } (dsp.exec command)
              )
              {
                XF86AudioRaiseVolume = "${volume} --inc";
                XF86AudioLowerVolume = "${volume} --dec";
                XF86AudioMute = "${volume} --toggle";
                XF86AudioMicMute = "${volume} --mic-toggle";
              }
          );

        gesture = [
          {
            fingers = 3;
            direction = "vertical";
            action = "fullscreen";
            mode = "maximize";
          }
          {
            fingers = 4;
            direction = "horizontal";
            action = "workspace";
          }
          {
            fingers = 4;
            direction = "vertical";
            scale = 0.6;
            action = "special";
            workspace_name = "code";
          }
        ];

      };
  };
}
