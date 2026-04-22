{
  config,
  lib,
  inputs',
  ...
}:
let
  llmCfg = config.programs.llm-cli;
in
{
  imports = [ ./providers.nix ];

  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode = {
      # FIXME: https://github.com/anomalyco/opencode/issues/23256
      # package = inputs'.opencode.packages.opencode;
      tui.keybinds = {
        leader = "ctrl+o";
        app_exit = "ctrl+q";
      };
      settings = {
        plugin = [
          "opencode-gemini-auth@latest"
          "@simonwjackson/opencode-direnv"
        ];
        share = "manual";
        autoupdate = false;
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
        instructions = llmCfg.projectInstructions;
      };
      skills = llmCfg.skills |> lib.mapAttrs (_: content: toString content);
      commands =
        llmCfg.commands
        |> lib.mapAttrs (
          _: cmd: ''
            ---
            description: ${cmd.description}
            ---

            ${cmd.prompt}
          ''
        );
    };

    home.persistence."/persist".directories = [
      ".config/opencode"
    ];
  };
}
