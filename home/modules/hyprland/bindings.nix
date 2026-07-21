{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins;
let
  volumeControl = getExe pkgs.volume-control;
  workspaceKeys = genAttrs (10 |> genList (x: toString x)) (key: if key == "0" then "10" else key);
  vimDirections = {
    H = "l";
    L = "r";
    K = "u";
    J = "d";
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
              Tab = dsp.toggleLayout "scrolling" "master";
              E = dsp.layoutFor {
                scrolling = dsp.smartColumnToggle;
                master = "swapwithmaster";
              };
              # Hyprland 0.55 scrolling maximize is not reversible yet:
              # https://github.com/hyprwm/Hyprland/discussions/14380
              A = dsp.layoutFor {
                master = dsp.window.maximize;
              };

              "mouse:272" = opts { mouse = true; } dsp.window.drag;
              "mouse:273" = opts { mouse = true; } dsp.window.resize;
            }
            // mapActions dsp.focus vimDirections
            // mapActions dsp.window.move {
              Left = "l";
              Right = "r";
              Up = "u";
              Down = "d";
            }
            // mapActions dsp.workspace.focus workspaceKeys
            // mapActions dsp.workspace.toggleSpecial specialWorkspaces
            // mapActions (messages: opts { repeating = true; } (dsp.layoutFor messages)) {
              Semicolon = {
                scrolling = "colresize -0.1";
                master = "mfact -0.05";
              };
              Apostrophe = {
                scrolling = "colresize +0.1";
                master = "mfact +0.05";
              };
            }
          )
          ++ mainShift (
            mapActions dsp.window.move vimDirections
            // mapActions dsp.window.moveOrSwapScrollingColumn {
              H = "l";
              L = "r";
            }
            // mapActions dsp.window.moveToWorkspace workspaceKeys
            // mapActions (workspace: dsp.window.moveToWorkspace "special:${workspace}") specialWorkspaces
          )
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
                XF86AudioRaiseVolume = "${volumeControl} --inc";
                XF86AudioLowerVolume = "${volumeControl} --dec";
                XF86AudioMute = "${volumeControl} --toggle";
                XF86AudioMicMute = "${volumeControl} --mic-toggle";
              }
          );

        gesture = [
          {
            fingers = 3;
            direction = "horizontal";
            action = "scroll_move";
          }
          {
            fingers = 3;
            direction = "vertical";
            action = dsp.layoutFor {
              master = dsp.window.maximize;
            };
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
