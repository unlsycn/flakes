{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  zsh = getExe pkgs.zsh;
in
{
  imports = [ ./hyprland.nix ];

  config = mkIf config.programs.ghostty.enable {
    programs.ghostty.settings = {
      app-notifications = "no-clipboard-copy";
      background-opacity = 0.85;
      command = zsh;
      copy-on-select = "clipboard";
      cursor-style = "block";
      cursor-style-blink = false;

      font-family = [
        "Maple Mono NF"
        "Sarasa Mono SC"
      ];
      font-feature = [
        "calt"
        "dlig"
      ];
      font-shaping-break = "cursor";
      font-size = 14;
      keybind = [
        "alt+j=scroll_page_lines:1"
        "alt+k=scroll_page_lines:-1"
        "alt+d=scroll_page_fractional:0.5"
        "alt+u=scroll_page_fractional:-0.5"
      ];
      shell-integration-features = "no-cursor";

      window-decoration = "none";
      window-inherit-font-size = false;
      window-inherit-working-directory = false;
      window-padding-balance = false;
      window-padding-x = 8;
      window-padding-y = 8;
      working-directory = "home";
    };
  };
}
