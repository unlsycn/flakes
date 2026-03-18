{
  config,
  lib,
  inputs',
  ...
}:
let
  cfg = config.programs.opencode;
  llmCfg = config.programs.llm-cli;

  toFrontmatterCommand = _: cmd: ''
    ---
    description: ${cmd.description}
    ---

    ${cmd.prompt}
  '';
in
{
  imports = [ ./providers.nix ];

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      package = inputs'.opencode.packages.opencode;
      settings = {
        plugin = [
          "opencode-gemini-auth@latest"
          "@simonwjackson/opencode-direnv"
        ];
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
            "**/.private/**" = "deny";
            ".direnv" = "ask";
          };
          edit = "ask";
          glob = "allow";
          grep = "allow";
          list = "allow";
          bash = {
            "*" = "ask";
          }
          // lib.genAttrs llmCfg.allowedBashCommands (_: "allow");
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
      };
      commands = llmCfg.commands |> lib.mapAttrs toFrontmatterCommand;
    };

    home.persistence."/persist".directories = [
      ".config/opencode"
    ];
  };
}
