{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.gh;
  gitEditor = attrByPath [
    "programs"
    "git"
    "settings"
    "core"
    "editor"
  ] "" config;
in
{
  config = mkIf cfg.enable {
    programs.gh = {
      settings = {
        git_protocol = "ssh";
        editor = gitEditor;
        prompt = "enabled";
        prefer_editor_prompt = "disabled";
        pager = "";
        aliases = {
          co = "pr checkout";
        };
        http_unix_socket = "";
        browser = "";
        color_labels = "enabled";
        accessible_colors = "disabled";
        accessible_prompter = "disabled";
        spinner = "enabled";
      };
    };

    home.persistence."/persist".directories = [ ".config/gh" ];
  };
}
