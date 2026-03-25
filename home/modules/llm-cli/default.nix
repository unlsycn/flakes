{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.llm-cli;

  backendBin = {
    claude-code = getExe config.programs.claude-code.finalPackage;
    opencode = getExe config.programs.opencode.package;
    gemini-cli = getExe config.programs.gemini-cli.package;
    codex = getExe config.programs.codex.package;
  };

  mkCommandAlias =
    backend: cmd:
    {
      claude-code = "${backendBin.claude-code} /${cmd}";
      opencode = "${backendBin.opencode} --prompt /${cmd}";
      gemini-cli = "${backendBin.gemini-cli} -i /${cmd}";
      codex = "${backendBin.codex} exec ${escapeShellArg (cfg.commands.${cmd}.prompt)}";
    }
    .${backend};

  enabledBackends = filterAttrs (_: v: v) {
    claude-code = config.programs.claude-code.enable;
    opencode = config.programs.opencode.enable;
    gemini-cli = config.programs.gemini-cli.enable;
    codex = config.programs.codex.enable;
  };

  commandSubmodule = types.submodule {
    options = {
      description = mkOption { type = types.str; };
      prompt = mkOption { type = types.lines; };
    };
  };
in
{
  imports = [
    (mkRenamedOptionModule
      [ "programs" "llm-cli" "projectInstructionFiles" ]
      [
        "programs"
        "llm-cli"
        "projectInstructions"
      ]
    )
  ];

  options.programs.llm-cli = {
    defaultBackend = mkOption {
      type = types.enum (attrNames backendBin);
      default = "codex";
    };

    commands = mkOption {
      type = types.attrsOf commandSubmodule;
      default = { };
    };

    allowedBashCommands = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    projectInstructions = mkOption {
      type = types.listOf types.str;
      default = [
        "AGENTS.md"
        "CLAUDE.md"
        "GEMINI.md"
        "CONTRIBUTING.md"
      ];
    };
  };

  config = {
    programs.llm-cli = {
      commands.commit = {
        description = "Generate a commit message for the staged changes";
        prompt = ''
          Analyze staged changes and recent git history to generate a concise
          commit message following recent patterns.

          Default to a single subject line with no body. Only add a body when
          the change is not self-explanatory and the subject alone cannot
          convey *why* the change was made — e.g. working around an upstream
          bug or adapting to a breaking change. The body should explain
          rationale, not list individual file changes. Do not append
          Co-Authored-By trailers.

          Ask the user whether to proceed, then commit with --signoff.
        '';
      };

      allowedBashCommands = [
        "ls *"
        "cat *"
        "head *"
        "tail *"
        "wc *"
        "file *"
        "tree *"
        "which *"
        "grep *"
        "rg *"
        "sort *"
        "cut *"
        "uniq *"
        "diff *"
        "echo *"
        "pwd"
        "git diff *"
        "git log *"
        "git show *"
        "git status *"
        "git rev-parse *"
        "gh *"
        "nix eval *"
        "nix flake show *"
        "nix flake metadata *"
        "nix flake check *"
      ];
    };

    programs.zsh.shellAliases = mkIf (
      config.programs.zsh.enable && enabledBackends ? ${cfg.defaultBackend}
    ) { gcm = mkCommandAlias cfg.defaultBackend "commit"; };
  };
}
