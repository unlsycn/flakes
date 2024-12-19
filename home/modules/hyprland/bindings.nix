{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins;
let
  bindingUtils = import ./lib/binding-utils.nix { inherit lib; };

  switch_workspace = "${pkgs.desktop-scripts}/bin/switch_workspace";
  volume = "${pkgs.desktop-scripts}/bin/volume";
in
with bindingUtils;
{
  config = mkIf config.wayland.windowManager.hyprland.enable {
    # See https://wiki.hyprland.org/Configuring/Keywords/
    wayland.windowManager.hyprland.settings = {
      bind =
        # Layout
        mainBind {
          X = "killactive";
          P = "togglefloating";
          B = "togglesplit"; # dwindle
          E = "layoutmsg, swapwithmaster"; # master
        }
        # Move focus with mainMod + arrow keys
        ++ bindWithDispatcher mainBind "movefocus" {
          H = "l";
          L = "r";
          K = "u";
          J = "d";
        }
        # Window: move in direction
        ++ bindWithDispatcher' "movewindow" {
          ${mainModifier} = {
            Left = "l";
            Right = "r";
            Up = "u";
            Down = "d";
          };
          ${mainShiftModifier} = {
            H = "l";
            L = "r";
            K = "u";
            J = "d";
          };
        }
        ++ mainBind {
          A = "fullscreen, 1";
        }
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        ++ flatten (
          map (f: f (genAttrs (genList (x: toString x) 10) (key: if key == "0" then "10" else key))) [
            (bindWithDispatcher mainBind "workspace")
            (bindWithDispatcher mainShiftBind "movetoworkspace")
          ]
        )
        # Special workspaces
        ++ flatten (
          mapAttrsToList
            (
              key: workspace:
              mainBind { ${key} = "togglespecialworkspace, ${workspace}"; }
              ++ mainShiftBind { ${key} = "movetoworkspace, special:${workspace}"; }
            )
            {
              F = "code";
              C = "chat";
              R = "remote";
            }
        )
        # Scroll through existing workspaces with mainMod + scroll or Alt + Tab
        ++ bindWithDispatcher' "exec" {
          ${mainModifier} = {
            mouse_down = "${switch_workspace} -p";
            mouse_up = "${switch_workspace}";
          };
          ${mainShiftModifier} = {
            mouse_down = "${switch_workspace} -pm";
            mouse_up = "${switch_workspace} -m";
          };
        }
        ++ bindWithDispatcher' "exec" {
          ${usualModifier} = {
            Tab = "${switch_workspace}";
          };
          "${usualModifier} Shift" = {
            Tab = "${switch_workspace} -p";
          };
        };
      # TODO: screenshot

      binde =
        # Window: split ratio +/- 0.1
        bindWithDispatcher mainBind "splitratio" {
          Minus = "-0.1";
          Equal = "+0.1";
          Semicolon = "-0.1";
          Apostrophe = "+0.1";
        };

      bindel = bindWithDispatcher (bindKeys "") "exec" {
        XF86AudioRaiseVolume = "${volume} --inc";
        XF86AudioLowerVolume = "${volume} --dec";
        XF86AudioMute = "${volume} --toggle";
      };

      bindm =
        # Move/resize windows with mainMod + LMB/RMB and dragging
        mainBind {
          "mouse:272" = "movewindow";
          "mouse:273" = "resizewindow";
        };

    };
  };
}
