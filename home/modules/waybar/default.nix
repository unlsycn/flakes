{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  volume = "${pkgs.desktop-scripts}/bin/volume";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  blueman-manager = "${pkgs.blueman}/bin/blueman-manager";
in
{
  config = mkIf config.programs.waybar.enable {
    programs.waybar = {
      settings = {
        mainBar = {
          layer = "top";
          margin-top = 5;
          margin-left = 5;
          margin-right = 5;
          height = 35;
          spacing = 5;
          modules-left = [
            "hyprland/window"
          ];
          modules-center = [
            "hyprland/workspaces"
          ];
          modules-right = [
            "tray"
            "group/device"
            "network"
            "group/sysinfo"
            "clock"
          ] ++ optional config.services.swaync.enable "custom/swaync";
          "group/sysinfo" = {
            drawer.transition-left-to-right = false;
            orientation = "inherit";
            modules = [
              "battery"
              "cpu"
              "memory"
              "temperature"
            ];
          };
          "group/device" = {
            drawer.transition-left-to-right = false;
            orientation = "inherit";
            modules = [
              "pulseaudio"
              "backlight"
            ];
          };
          "hyprland/workspaces" = {
            active-only = false;
            all-outputs = true;
            format = "{icon}";
            show-special = false;
            on-click = "activate";
            on-scroll-up = "hyprctl dispatch workspace -1";
            on-scroll-down = "hyprctl dispatch workspace +1";
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
              "5" = [ ];
            };
            format-icons = {
              active = "<span font='12'>󰮯</span>";
              empty = "<span font='8'></span>";
              default = "󰊠";
            };
          };
          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };
          cpu = {
            format = "󰍛 {usage:0>2}%";
            interval = 1;
            min-length = 5;
            format-alt-click = "click";
            format-alt = "󰍛 {usage:0>2}% {icon0}{icon1}{icon2}{icon3}";
            format-icons = [
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▇"
              "█"
            ];
          };
          memory = {
            format = " {}%";
          };
          temperature = {
            critical-threshold = 80;
            format = "{icon} {temperatureC}°C";
            format-icons = [
              ""
              ""
            ];
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-full = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{time} {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          network = {
            format-wifi = "  {signalStrength}%";
            format-ethernet = " {ifname}";
            tooltip-format = "{ifname} via {gwaddr}";
            format-linked = "󰊗 {ifname} (No IP)";
            format-disconnected = "";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
          "backlight" = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = [
              ""
              ""
            ];
            tooltip-format = "{icon} Brightness | {percent}%";
            on-scroll-up = "${brightnessctl} s +5%";
            on-scroll-down = "${brightnessctl} s 5%-";
            smooth-scrolling-threshold = 1;
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} 󰂰 {volume}%";
            format-muted = "󰖁";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                "󰕾"
                ""
              ];
              ignored-sinks = [
                "Easy Effects Sink"
              ];
            };
            scroll-step = 5;
            on-click = "${volume} --toggle";
            on-scroll-up = "${volume} --inc";
            on-scroll-down = "${volume} --dec";
            tooltip-format = "{icon} {desc} | {volume}%";
            smooth-scrolling-threshold = 1;
          };
          bluetooth = {
            format = "";
            format-disabled = "󰂲";
            format-connected = "󰂱 {num_connections}";
            tooltip-format = " {device_alias}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = " {device_alias} 󰁹{evice_battery_percentage}%";
            tooltip = true;
            on-click = "${blueman-manager}";
          };
          "custom/swaync" = {
            tooltip = true;
            format = "{icon}";
            format-icons = {
              notification = "<span foreground='#ed8796'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='#ed8796'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='#ed8796'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='#ed8796'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec = "${swaync-client} -swb";
            on-click = "sleep 0.1 && ${swaync-client} -t -sw";
            on-click-right = "${swaync-client} -d -sw";
            escape = true;
          };
          tray = {
            icon-size = 22;
            spacing = 8;
          };
        };
      };
      style = ./style.css;

      systemd.enable = true;
    };
  };

}
