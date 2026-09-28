{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.sioyek;
in
with lib;
{
  imports = [ ./ask-omp.nix ];

  config = mkIf cfg.enable {
    programs.sioyek = {
      config = {
        startup_commands = [ "toggle_custom_color" ];
        # catppuccin's single-value #7f849c is rejected (this option wants RGBA), so override it
        visual_mark_color = "0.5 0.52 0.61 0.3";
        should_launch_new_window = "1";
        should_use_multiple_monitors = "1";
        should_load_tutorial_when_no_other_file = "0";
        wheel_zoom_on_cursor = "1";
        super_fast_search = "1";
        linear_filter = "1";
      };

      bindings = {
        open_last_document = "gl";
        embed_annotations = "E";
        toggle_statusbar = "<C-s>";

        next_page = "J";
        previous_page = "K";
        # <home>'s goto-page prompt; gn/gN are off-limits (prefixes of gnh/gNh)
        goto_page_with_page_number = "gt";

        toggle_select_highlight = "za";
        toggle_custom_color = "zc";
        toggle_dark_mode = "zd";
        toggle_fullscreen = "zf";
        fit_to_page_height_smart = "zh";
        toggle_horizontal_scroll_lock = "zl";
        toggle_mouse_drag_mode = "zm";
        keyboard_overview = "zo";
        toggle_presentation_mode = "zp";
        reload = "zr";
        toggle_synctex = "zs";
        toggle_visual_scroll = "zv";
        fit_to_page_width_smart = "zw";
        close_overview = "zx";

        open_selected_url = "u";
        goto_window = "w";
      };
    };

    home.packages = [ cfg.package ];

    xdg.mimeApps.defaultApplicationPackages = [ cfg.package ];

    home.persistence."/persist".directories = [
      ".local/share/sioyek"
    ];
  };
}
