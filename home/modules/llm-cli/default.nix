{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  hmzCfg = config.programs.llm-cli.humanize;
  humanizeRuntime = pkgs.humanize.runtime;
  backendBin = {
    claude-code = getExe config.programs.claude-code.finalPackage;
    opencode = getExe config.programs.opencode.package;
    antigravity-cli = getExe config.programs.antigravity-cli.package;
    codex = getExe config.programs.codex.package;
  };
in
{
  options.programs.llm-cli = {
    defaultBackend = mkOption {
      type = types.enum (attrNames backendBin);
      default = "codex";
    };

    commands = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            description = mkOption { type = types.str; };
            prompt = mkOption { type = types.lines; };
          };
        }
      );
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

    codexSkills = mkOption {
      type = types.attrsOf types.path;
      default = { };
    };

    claudePlugins = mkOption {
      type = with types; listOf (either package path);
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

    humanize = {
      enable = mkEnableOption "humanize" // {
        default = true;
      };
      monitor.enable = mkEnableOption "humanize CLI wrapper" // {
        default = hmzCfg.enable;
      };
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
      ]
      ++ optionals hmzCfg.enable [
        (unsafeDiscardStringContext "${humanizeRuntime}/scripts/*")
        (unsafeDiscardStringContext "${humanizeRuntime}/scripts/* *")
        (unsafeDiscardStringContext "${humanizeRuntime}/hooks/*")
      ];

      skills = {
        commit-message = pkgs."commit-message";
        typst = pkgs."claude-skill-typst";
      };

      codexSkills = optionalAttrs hmzCfg.enable {
        humanize = pkgs.humanize.humanize;
        "humanize-gen-plan" = pkgs.humanize."humanize-gen-plan";
        "humanize-refine-plan" = pkgs.humanize."humanize-refine-plan";
        "humanize-rlcr" = pkgs.humanize."humanize-rlcr";
      };

      claudePlugins = optionals hmzCfg.enable [ pkgs.humanize.claudePlugin ];
    };

    home.packages = optionals hmzCfg.monitor.enable [ pkgs.humanize.humanizeWrapper ];

    programs.zsh.shellAliases =
      mkIf
        (
          config.programs.zsh.enable
          && (filterAttrs (_: v: v) {
            claude-code = config.programs.claude-code.enable;
            opencode = config.programs.opencode.enable;
            antigravity-cli = config.programs.antigravity-cli.enable;
            codex = config.programs.codex.enable;
          }) ? ${config.programs.llm-cli.defaultBackend}
        )
        {
          gcm =
            {
              claude-code = "${backendBin.claude-code} /commit-message";
              opencode = "${backendBin.opencode} --prompt /commit-message";
              antigravity-cli = "${backendBin.antigravity-cli} -i /commit-message";
              codex = "${backendBin.codex} ${escapeShellArg "$commit-message"}";
            }
            .${config.programs.llm-cli.defaultBackend};
        };
  };
}
