{
  config,
  lib,
  inputs',
  ...
}:
let
  cfg = config.programs.opencode;
in
{
  config = lib.mkIf cfg.enable {
    programs.opencode = {
      package = inputs'.opencode.packages.opencode;
      settings = {
        plugin = [ "opencode-gemini-auth@latest" ];
        model = "google/gemini-3-pro-preview";
        small_model = "google/gemini-3-flash-preview";
        share = "manual";
        autoupdate = false;
        keybinds = {
          leader = "ctrl+o";
          app_exit = "ctrl+q";
        };
        permission = {
          read = {
            "*" = "allow";
            "*.env" = "deny";
            ".direnv" = "ask";
          };
          edit = "ask";
          glob = "allow";
          grep = "allow";
          list = "allow";
          bash = {
            "*" = "ask";
            "ls *" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
            "git diff *" = "allow";
            "git log *" = "allow";
            "git status *" = "allow";
          };
          task = "ask";
          skill = "allow";
          lsp = "allow";
          todoread = "allow";
          todowrite = "allow";
          question = "ask";
          webfetch = "ask";
          #{  TODO: https://github.com/anomalyco/opencode/issues/7445
          #   "*" = "ask";
          #   "*.github.com" = "allow";
          #   "*.githubusercontent.com" = "allow";
          # };
          websearch = "allow";
          codesearch = "allow";
          external_directory = "ask";
          doom_loop = "ask";
        };
        compaction = {
          auto = true;
          prune = true;
        };
        instructions = [
          "CONTRIBUTING.md"
          "CLAUDE.md"
          "GEMINI.md"
        ];
        enabled_providers = [
          "google"
          "deepseek"
        ];
      };
      commands = {
        "commit" = ''
          ---
          description: Generate a commit message for the staged changes
          agent: build
          ---

          Please analyze staged changes and recent git history to generate a concise commit message, following recent patterns. Only include a body if necessary to explain the rationale.

          After generating the message, ask the user if they want to proceed with the commit. If confirmed, execute the commit with the `--signoff` flag.
        '';
      };
    };

    home.persistence."/persist".directories = [
      ".config/opencode"
    ];
  };
}
