{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  bindingUtils = import ./lib/binding-utils.nix { inherit lib; };
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
        ++ flatten (
          mapAttrsToList (name: value: bindWithDispatcher (bindKeys name) "movewindow" value) {
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
        )
        ++ mainBind {
          A = "fullscreen, 1";
        }
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        ++ flatten (
          map (f: f (genAttrs (genList (x: toString x) 10) (name: if name == "0" then "10" else name))) [
            (bindWithDispatcher mainBind "workspace")
            (bindWithDispatcher mainShiftBind "movetoworkspace")
          ]
        )
        # Special workspaces
        ++ flatten (
          mapAttrsToList
            (
              name: value:
              mainBind { ${name} = "togglespecialworkspace, ${value}"; }
              ++ mainShiftBind { ${name} = "movetoworkspace, special:${value}"; }
            )
            {
              F = "code";
              C = "chat";
              R = "remote";
            }
        );
      # TODO: switch_workspace
      # TODO: screenshot
      # TODO: volume

      binde =
        # Window: split ratio +/- 0.1
        bindWithDispatcher mainBind "splitratio" {
          Minus = "-0.1";
          Equal = "+0.1";
          Semicolon = "-0.1";
          Apostrophe = "+0.1";
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
