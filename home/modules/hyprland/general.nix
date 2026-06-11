{ config, lib, ... }:
with lib;
let
  mkBezier = name: x0: y0: x1: y1: {
    _args = [
      name
      {
        type = "bezier";
        points = [
          [
            x0
            y0
          ]
          [
            x1
            y1
          ]
        ];
      }
    ];
  };

  mkAnimation =
    leaf: speed: bezier: style:
    {
      inherit leaf speed bezier;
      enabled = true;
    }
    // optionalAttrs (style != null) { inherit style; };
in
{
  config = mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      config = {
        input = {
          kb_layout = "us";
          numlock_by_default = true;
          repeat_delay = 250;
          repeat_rate = 35;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
            drag_lock = true;
            scroll_factor = 0.5;
          };
          special_fallthrough = true;
          follow_mouse = 2;
          float_switch_override_focus = 0;

          accel_profile = "custom 0.32167162584878306 0.000 0.100 0.201 0.352 0.503 0.654 0.818 1.048 1.277 1.507 1.736 1.966 2.195 2.425 2.654 2.884 3.113 3.343 3.572 4.046";
        };

        binds = {
          scroll_event_delay = 0;
          movefocus_cycles_fullscreen = true;
        };

        gestures = {
          workspace_swipe_distance = 700;
          workspace_swipe_cancel_ratio = 0.2;
          workspace_swipe_min_speed_to_force = 5;
          workspace_swipe_direction_lock = true;
          workspace_swipe_direction_lock_threshold = 10;
          workspace_swipe_create_new = true;
        };

        general = {
          gaps_in = 4;
          gaps_out = 5;
          border_size = 1;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col = {
            active_border = "rgba(0DB7D4FF)";
            inactive_border = "rgba(31313600)";
          };

          resize_on_border = true;
          no_focus_fallback = true;
          layout = "master";

          allow_tearing = true; # This just allows the `immediate` window rule to work
        };

        # https://wiki.hyprland.org/Configuring/Master-Layout
        master = {
          new_status = "master";
          new_on_top = true;
        };

        # https://wiki.hyprland.org/Configuring/Dwindle-Layout
        dwindle = {
          preserve_split = true;
          smart_split = false;
        };

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration = {
          rounding = 10;

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            new_optimizations = true;
            size = 3;
            passes = 2;
            xray = false;
            special = false;
            popups = true;
            popups_ignorealpha = 0.6;
          };

          shadow = {
            enabled = true;
            range = 20;
            offset = [
              0
              2
            ];
            render_power = 4;
            color = "rgba(0000002A)";
          };

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          dim_inactive = false;
          dim_strength = 0.1;
          dim_special = 0;
        };

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations.enabled = true;

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc = {
          vrr = 1;
          focus_on_activate = true;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          enable_swallow = true;

          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          on_focus_under_fullscreen = 2;
          allow_session_lock_restore = true;
          middle_click_paste = false;

          initial_workspace_tracking = false;
        };

        xwayland.force_zero_scaling = true;
      };

      # https://wiki.hyprland.org/Configuring/Advanced-and-Cool/Animations/#curves
      curve = [
        (mkBezier "linear" 0 0 1 1)
        (mkBezier "md3_standard" 0.2 0 0 1)
        (mkBezier "md3_decel" 0.05 0.7 0.1 1)
        (mkBezier "md3_accel" 0.3 0 0.8 0.15)
        (mkBezier "overshot" 0.05 0.9 0.1 1.1)
        (mkBezier "crazyshot" 0.1 1.5 0.76 0.92)
        (mkBezier "hyprnostretch" 0.05 0.9 0.1 1.0)
        (mkBezier "menu_decel" 0.1 1 0 1)
        (mkBezier "menu_accel" 0.38 0.04 1 0.07)
        (mkBezier "easeInOutCirc" 0.85 0 0.15 1)
        (mkBezier "easeOutCirc" 0 0.55 0.45 1)
        (mkBezier "easeOutExpo" 0.16 1 0.3 1)
        (mkBezier "softAcDecel" 0.26 0.26 0.15 1)
        (mkBezier "md2" 0.4 0 0.2 1)
      ];

      # https://wiki.hyprland.org/Configuring/Advanced-and-Cool/Animations/
      animation = [
        (mkAnimation "windows" 3 "md3_decel" "popin 60%")
        (mkAnimation "windowsIn" 3 "md3_decel" "popin 60%")
        (mkAnimation "windowsOut" 3 "md3_accel" "popin 60%")
        (mkAnimation "border" 10 "default" null)
        (mkAnimation "fade" 3 "md3_decel" null)
        (mkAnimation "layersIn" 3 "menu_decel" "slide")
        (mkAnimation "layersOut" 1.6 "menu_accel" null)
        (mkAnimation "fadeLayersIn" 2 "menu_decel" null)
        (mkAnimation "fadeLayersOut" 4.5 "menu_accel" null)
        (mkAnimation "workspaces" 7 "menu_decel" "slide")
        (mkAnimation "specialWorkspace" 3 "md3_decel" "slidevert")
      ];
    };

  };
}
