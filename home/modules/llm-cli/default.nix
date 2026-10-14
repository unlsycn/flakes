{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.llm-cli;
  humanizeRuntime = pkgs.humanize.runtime;
  commitMessageCommand = {
    claude-code = "${getExe config.programs.claude-code.finalPackage} /commit-message";
    opencode = "${getExe config.programs.opencode.package} --prompt /commit-message";
    antigravity-cli = "${getExe config.programs.antigravity-cli.package} -i /commit-message";
    codex = "${getExe config.programs.codex.package} ${escapeShellArg "$commit-message"}";
    omp = "${getExe config.programs.omp.finalPackage} /commit-message";
  };
in
{
  options.programs.llm-cli = {
    defaultBackend = mkOption {
      type = types.enum (attrNames commitMessageCommand);
      default = "omp";
    };

    gateway = {
      url = mkOption {
        type = types.str;
        default = "https://llm.ts.unlsycn.com";
      };

      apiKeyFile = mkOption {
        type = types.nullOr types.str;
        default =
          if config.sops.control.deploySecrets then config.sops.secrets.senesperejo-client-key.path else null;
      };
    };

    commands = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          {
            options = {
              description = mkOption { type = types.str; };
              prompt = mkOption { type = types.lines; };
              markdown = mkOption {
                type = types.str;
                readOnly = true;
                default = ''
                  ---
                  description: ${config.description}
                  ---

                  ${config.prompt}
                '';
              };
            };
          }
        )
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
      type = with types; attrsOf (either package path);
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

    humanize = {
      enable = mkEnableOption "humanize" // {
        default = false;
      };
      monitor.enable = mkEnableOption "humanize CLI wrapper" // {
        default = cfg.humanize.enable;
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
      ++ optionals cfg.humanize.enable [
        (unsafeDiscardStringContext "${humanizeRuntime}/scripts/*")
        (unsafeDiscardStringContext "${humanizeRuntime}/scripts/* *")
        (unsafeDiscardStringContext "${humanizeRuntime}/hooks/*")
      ];

      skills = {
        commit-message = pkgs."commit-message";
        typst = pkgs."claude-skill-typst";
      };

      codexSkills = optionalAttrs cfg.humanize.enable {
        humanize = pkgs.humanize.humanize;
        "humanize-gen-plan" = pkgs.humanize."humanize-gen-plan";
        "humanize-refine-plan" = pkgs.humanize."humanize-refine-plan";
        "humanize-rlcr" = pkgs.humanize."humanize-rlcr";
      };

      claudePlugins = mkIf cfg.humanize.enable { humanize = pkgs.humanize.claudePlugin; };
    };

    home.packages = optionals cfg.humanize.monitor.enable [ pkgs.humanize.humanizeWrapper ];

    sops.secrets.senesperejo-client-key = mkIf config.sops.control.deploySecrets {
      sopsFile = ../../../system/modules/cliproxyapi/secrets.yaml;
      key = "client-key";
    };

    programs.zsh.shellAliases =
      mkIf (config.programs.zsh.enable && config.programs.${cfg.defaultBackend}.enable)
        {
          gcm = commitMessageCommand.${cfg.defaultBackend};
        };
  };
}
