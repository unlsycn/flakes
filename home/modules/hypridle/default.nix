{
  config,
  lib,
  pkgs,
  ...
}:
let
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
in
with lib;
{
  config = mkIf config.services.hypridle.enable {
    services.hypridle.settings = {
      general = {
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
      };

      listener = [
        {
          timeout = 1140;
          on-timeout = "${notify-send} 'You are idle!'";
          on-resume = "${notify-send} 'Welcome back'";
        }
        {
          timeout = 1200;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "${systemctl} suspend";
        }
      ];
    };
  };
}
