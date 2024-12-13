{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  zsh = "${pkgs.zsh}/bin/zsh";
in
{
  imports = [ ./hyprland.nix ];

  config = mkIf config.programs.alacritty.enable {
    programs.alacritty.settings = {
      env = {
        TERM = "xterm-256color";
      };

      font = {
        size = 14;
        normal = {
          family = "Jetbrains Mono";
        };
      };

      keyboard = {
        bindings = [
          {
            action = "ToggleViMode";
            key = "Enter";
            mode = "~Search";
            mods = "Control";
          }
          {
            action = "ToggleViMode";
            key = "Escape";
            mode = "Vi";
          }
        ];
      };

      selection.save_to_clipboard = true;

      terminal.shell.program = zsh;

      window = {
        decorations = "None";
        dynamic_padding = false;
        opacity = 0.85;
        padding = {
          x = 8;
          y = 8;
        };
      };

      general.live_config_reload = true;

      colors = import ./colors.nix;
    };
  };
}
