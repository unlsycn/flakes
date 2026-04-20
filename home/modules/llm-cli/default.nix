{
  config,
  lib,
  pkgs,
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

  mkSkillAlias =
    backend: skill:
    {
      claude-code = "${backendBin.claude-code} /${skill}";
      opencode = "${backendBin.opencode} --prompt /${skill}";
      gemini-cli = "${backendBin.gemini-cli} -i /${skill}";
      codex = "${backendBin.codex} ${escapeShellArg ("$" + skill)}";
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

    skills = mkOption {
      type = types.attrsOf types.path;
      default = { };
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

      skills = {
        commit-message = pkgs."commit-message";
        brainstorming = pkgs.superpowers.brainstorming;
        dispatching-parallel-agents = pkgs.superpowers."dispatching-parallel-agents";
        executing-plans = pkgs.superpowers."executing-plans";
        finishing-a-development-branch = pkgs.superpowers."finishing-a-development-branch";
        receiving-code-review = pkgs.superpowers."receiving-code-review";
        requesting-code-review = pkgs.superpowers."requesting-code-review";
        routing-superpowers = pkgs."routing-superpowers";
        subagent-driven-development = pkgs.superpowers."subagent-driven-development";
        systematic-debugging = pkgs.superpowers."systematic-debugging";
        test-driven-development = pkgs.superpowers."test-driven-development";
        using-git-worktrees = pkgs.superpowers."using-git-worktrees";
        verification-before-completion = pkgs.superpowers."verification-before-completion";
        writing-plans = pkgs.superpowers."writing-plans";
        writing-skills = pkgs.superpowers."writing-skills";
      };
    };
    programs.zsh.shellAliases = mkIf (
      config.programs.zsh.enable && enabledBackends ? ${cfg.defaultBackend}
    ) { gcm = mkSkillAlias cfg.defaultBackend "commit-message"; };
  };
}
