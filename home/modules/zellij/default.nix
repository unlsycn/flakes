{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.zellij;
  ghost = pkgs.fetchurl {
    url = "https://github.com/vdbulcke/ghost/releases/download/v0.6.0/ghost.wasm";
    hash = "sha256-+/TfnIimyhNYzYerxD+FhXkPpIbldWPPJrjsTdPwO4c=";
  };
  room = pkgs.fetchurl {
    url = "https://github.com/rvcas/room/releases/download/v1.2.0/room.wasm";
    hash = "sha256-t6GPP7OOztf6XtBgzhLF+edUU294twnu0y5uufXwrkw=";
  };
in
with builtins;
{
  options.programs.zellij.copyCommand = mkOption {
    type = types.str;
    default = "wl-copy";
  };

  config = mkIf cfg.enable {
    programs.zellij.settings =
      let
        multiKeys = concatStringsSep "\" \"";
        bindKey = bindings: bindings |> mapAttrs' (key: action: nameValuePair "bind \"${key}\"" action);
        unbindKeys = unbindList: {
          ${"unbind " + (concatMapStringsSep " " (key: "\"${key}\"") unbindList)} = { };
        };
      in
      {
        keybinds = {
          _props.clear-defaults = true;

          locked = bindKey {
            "Ctrl g" = {
              SwitchToMode = "Normal";
            };
          };

          resize = bindKey {
            "Ctrl n" = {
              SwitchToMode = "Normal";
            };
            ${
              multiKeys [
                "h"
                "Left"
              ]
            } =
              {
                Resize = "Increase Left";
              };
            ${
              multiKeys [
                "j"
                "Down"
              ]
            } =
              {
                Resize = "Increase Down";
              };
            ${
              multiKeys [
                "k"
                "Up"
              ]
            } =
              {
                Resize = "Increase Up";
              };
            ${
              multiKeys [
                "l"
                "Right"
              ]
            } =
              {
                Resize = "Increase Right";
              };
            "H" = {
              Resize = "Decrease Left";
            };
            "J" = {
              Resize = "Decrease Down";
            };
            "K" = {
              Resize = "Decrease Up";
            };
            "L" = {
              Resize = "Decrease Right";
            };
            ${
              multiKeys [
                "="
                "+"
              ]
            } =
              {
                Resize = "Increase";
              };
            "-" = {
              Resize = "Decrease";
            };
          };

          pane = bindKey {
            "Ctrl b" = {
              SwitchToMode = "Normal";
            };
            ${
              multiKeys [
                "h"
                "Left"
              ]
            } =
              {
                MoveFocus = "Left";
              };
            ${
              multiKeys [
                "l"
                "Right"
              ]
            } =
              {
                MoveFocus = "Right";
              };
            ${
              multiKeys [
                "j"
                "Down"
              ]
            } =
              {
                MoveFocus = "Down";
              };
            ${
              multiKeys [
                "k"
                "Up"
              ]
            } =
              {
                MoveFocus = "Up";
              };
            "p" = {
              SwitchFocus = { };
            };
            "n" = {
              NewPane = { };
              SwitchToMode = "Normal";
            };
            "d" = {
              NewPane = "Down";
              SwitchToMode = "Normal";
            };
            "r" = {
              NewPane = "Right";
              SwitchToMode = "Normal";
            };
            "x" = {
              CloseFocus = { };
              SwitchToMode = "Normal";
            };
            "f" = {
              ToggleFocusFullscreen = { };
              SwitchToMode = "Normal";
            };
            "z" = {
              TogglePaneFrames = { };
              SwitchToMode = "Normal";
            };
            "w" = {
              ToggleFloatingPanes = { };
              SwitchToMode = "Normal";
            };
            "e" = {
              TogglePaneEmbedOrFloating = { };
              SwitchToMode = "Normal";
            };
            "c" = {
              SwitchToMode = "RenamePane";
              PaneNameInput = 0;
            };
          };

          move = bindKey {
            "Ctrl h" = {
              SwitchToMode = "Normal";
            };
            ${
              multiKeys [
                "n"
                "Tab"
              ]
            } =
              {
                MovePane = { };
              };
            "p" = {
              MovePaneBackwards = { };
            };
            ${
              multiKeys [
                "h"
                "Left"
              ]
            } =
              {
                MovePane = "Left";
              };
            ${
              multiKeys [
                "j"
                "Down"
              ]
            } =
              {
                MovePane = "Down";
              };
            ${
              multiKeys [
                "k"
                "Up"
              ]
            } =
              {
                MovePane = "Up";
              };
            ${
              multiKeys [
                "l"
                "Right"
              ]
            } =
              {
                MovePane = "Right";
              };
          };

          tab = bindKey {
            "Ctrl t" = {
              SwitchToMode = "Normal";
            };
            "r" = {
              SwitchToMode = "RenameTab";
              TabNameInput = 0;
            };
            ${
              multiKeys [
                "h"
                "Left"
                "Up"
                "k"
              ]
            } =
              {
                GoToPreviousTab = { };
              };
            ${
              multiKeys [
                "l"
                "Right"
                "Down"
                "j"
              ]
            } =
              {
                GoToNextTab = { };
              };
            "n" = {
              NewTab = { };
              SwitchToMode = "Normal";
            };
            "x" = {
              CloseTab = { };
              SwitchToMode = "Normal";
            };
            "s" = {
              ToggleActiveSyncTab = { };
              SwitchToMode = "Normal";
            };
            "b" = {
              BreakPane = { };
              SwitchToMode = "Normal";
            };
            "]" = {
              BreakPaneRight = { };
              SwitchToMode = "Normal";
            };
            "[" = {
              BreakPaneLeft = { };
              SwitchToMode = "Normal";
            };
            "1" = {
              GoToTab = 1;
              SwitchToMode = "Normal";
            };
            "2" = {
              GoToTab = 2;
              SwitchToMode = "Normal";
            };
            "3" = {
              GoToTab = 3;
              SwitchToMode = "Normal";
            };
            "4" = {
              GoToTab = 4;
              SwitchToMode = "Normal";
            };
            "5" = {
              GoToTab = 5;
              SwitchToMode = "Normal";
            };
            "6" = {
              GoToTab = 6;
              SwitchToMode = "Normal";
            };
            "7" = {
              GoToTab = 7;
              SwitchToMode = "Normal";
            };
            "8" = {
              GoToTab = 8;
              SwitchToMode = "Normal";
            };
            "9" = {
              GoToTab = 9;
              SwitchToMode = "Normal";
            };
            "Tab" = {
              ToggleTab = { };
            };
          };

          scroll = bindKey {
            "Ctrl u" = {
              SwitchToMode = "Normal";
            };
            "e" = {
              EditScrollback = { };
              SwitchToMode = "Normal";
            };
            "s" = {
              SwitchToMode = "EnterSearch";
              SearchInput = 0;
            };
            "Ctrl c" = {
              ScrollToBottom = { };
              SwitchToMode = "Normal";
            };
            ${
              multiKeys [
                "j"
                "Down"
              ]
            } =
              {
                ScrollDown = { };
              };
            ${
              multiKeys [
                "k"
                "Up"
              ]
            } =
              {
                ScrollUp = { };
              };
            ${
              multiKeys [
                "Ctrl f"
                "PageDown"
                "Right"
                "l"
              ]
            } =
              {
                PageScrollDown = { };
              };
            ${
              multiKeys [
                "Ctrl b"
                "PageUp"
                "Left"
                "h"
              ]
            } =
              {
                PageScrollUp = { };
              };
            "d" = {
              HalfPageScrollDown = { };
            };
            "u" = {
              HalfPageScrollUp = { };
            };
          };

          session = bindKey {
            "Ctrl o" = {
              SwitchToMode = "Normal";
            };
            "Ctrl u" = {
              SwitchToMode = "Scroll";
            };
            "q" = {
              Quit = { };
            };
            "d" = {
              Detach = { };
            };
            "w" = {
              LaunchOrFocusPlugin = {
                _args = [ "zellij:session-manager" ];
                floating = true;
                move_to_focused_tab = true;
              };
              SwitchToMode = "Normal";
            };
          };

          tmux = bindKey {
            "[" = {
              SwitchToMode = "Scroll";
            };
            "Ctrl a" = {
              Write = 2;
              SwitchToMode = "Normal";
            };
            "\\\"" = {
              NewPane = "Down";
              SwitchToMode = "Normal";
            };
            "%" = {
              NewPane = "Right";
              SwitchToMode = "Normal";
            };
            "z" = {
              ToggleFocusFullscreen = { };
              SwitchToMode = "Normal";
            };
            "c" = {
              NewTab = { };
              SwitchToMode = "Normal";
            };
            "," = {
              SwitchToMode = "RenameTab";
            };
            "p" = {
              GoToPreviousTab = { };
              SwitchToMode = "Normal";
            };
            "n" = {
              GoToNextTab = { };
              SwitchToMode = "Normal";
            };
            "Left" = {
              MoveFocus = "Left";
              SwitchToMode = "Normal";
            };
            "Right" = {
              MoveFocus = "Right";
              SwitchToMode = "Normal";
            };
            "Down" = {
              MoveFocus = "Down";
              SwitchToMode = "Normal";
            };
            "Up" = {
              MoveFocus = "Up";
              SwitchToMode = "Normal";
            };
            "h" = {
              MoveFocus = "Left";
              SwitchToMode = "Normal";
            };
            "l" = {
              MoveFocus = "Right";
              SwitchToMode = "Normal";
            };
            "j" = {
              MoveFocus = "Down";
              SwitchToMode = "Normal";
            };
            "k" = {
              MoveFocus = "Up";
              SwitchToMode = "Normal";
            };
            "o" = {
              FocusNextPane = { };
            };
            "d" = {
              Detach = { };
            };
            "Space" = {
              NextSwapLayout = { };
            };
            "x" = {
              CloseFocus = { };
              SwitchToMode = "Normal";
            };
          };

          "shared_except \"locked\"" = bindKey {
            "Ctrl g" = {
              SwitchToMode = "Locked";
            };
            "Ctrl p" = {
              ToggleFloatingPanes = { };
            };
            "Ctrl q" = {
              Detach = { };
            };
            "Alt n" = {
              NewPane = { };
            };
            ${
              multiKeys [
                "Alt h"
                "Alt Left"
              ]
            } =
              {
                MoveFocusOrTab = "Left";
              };
            ${
              multiKeys [
                "Alt l"
                "Alt Right"
              ]
            } =
              {
                MoveFocusOrTab = "Right";
              };
            ${
              multiKeys [
                "Alt j"
                "Alt Down"
              ]
            } =
              {
                MoveFocus = "Down";
              };
            ${
              multiKeys [
                "Alt k"
                "Alt Up"
              ]
            } =
              {
                MoveFocus = "Up";
              };
            ${
              multiKeys [
                "Alt ="
                "Alt +"
              ]
            } =
              {
                Resize = "Increase";
              };
            "Alt -" = {
              Resize = "Decrease";
            };
            "Alt [" = {
              PreviousSwapLayout = { };
            };
            "Alt ]" = {
              NextSwapLayout = { };
            };
            "Ctrl y" = {
              LaunchOrFocusPlugin = {
                _args = [ "file:${room}" ];
                floating = true;
                ignore_case = true;
              };
            };
            "Ctrl [" = {
              LaunchOrFocusPlugin = {
                _args = [ "file:${ghost}" ];
                floating = true;
                shell = "zsh";
                shell_flag = "-ic";
              };
            };
          };

          "shared_except \"normal\" \"locked\"" = bindKey {
            ${
              multiKeys [
                "Enter"
                "Esc"
              ]
            } =
              {
                SwitchToMode = "Normal";
              };
          };

          "shared_except \"pane\" \"locked\"" = bindKey {
            "Ctrl b" = {
              SwitchToMode = "Pane";
            };
          };

          "shared_except \"resize\" \"locked\"" = bindKey {
            "Ctrl n" = {
              SwitchToMode = "Resize";
            };
          };

          "shared_except \"scroll\" \"locked\"" = bindKey {
            "Ctrl u" = {
              SwitchToMode = "Scroll";
            };
          };

          "shared_except \"session\" \"locked\"" = bindKey {
            "Ctrl o" = {
              SwitchToMode = "Session";
            };
          };

          "shared_except \"tab\" \"locked\"" = bindKey {
            "Ctrl t" = {
              SwitchToMode = "Tab";
            };
          };

          "shared_except \"move\" \"locked\"" = bindKey {
            "Ctrl h" = {
              SwitchToMode = "Move";
            };
          };

          "shared_except \"tmux\" \"locked\"" = bindKey {
            "Ctrl a" = {
              SwitchToMode = "Tmux";
            };
          };
        };

        simplified_ui = true;
        pane_frames = false;
        session_serialization = true;
        serialize_pane_viewport = true;
        show_startup_tips = false;
        scrollback_lines_to_serialize = 4096;
        layout_dir = "~/${config.xdg.configHome}/zellij/layouts";
      }
      // optionalAttrs (cfg.copyCommand != "") { copy_command = cfg.copyCommand; };
  };
}
