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
        # 白底黑字映射到 catppuccin base/text，图表原色保留（主题色板由 catppuccin source 注入）
        startup_commands = [ "toggle_custom_color" ];
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
      };
    };

    home.packages = [ cfg.package ];

    xdg.mimeApps.defaultApplicationPackages = [ cfg.package ];

    home.persistence."/persist".directories = [
      ".local/share/sioyek"
    ];
  };
}
