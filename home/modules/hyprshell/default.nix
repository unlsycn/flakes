{ config, lib, ... }:
with lib;
{
  config = mkIf config.services.hyprshell.enable {
    services.hyprshell = {
      systemd.args = "--config-file ${config.xdg.configHome}/hyprshell/config.json";

      settings = {
        version = 4;
        windows.switch = {
          modifier = "alt";
          key = "Tab";
          switch_workspaces = true;
          exclude_workspaces = "special:.*";
        };
      };
    };
  };
}
