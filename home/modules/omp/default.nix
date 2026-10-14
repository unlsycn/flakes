{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
with lib;
let
  cfg = config.programs.omp;
  llmCfg = config.programs.llm-cli;
  yaml = pkgs.formats.yaml { };
in
{
  imports = [ ./models.nix ];

  options.programs.omp = {
    enable = mkEnableOption "OMP coding agent";

    package = mkOption {
      type = types.package;
      default = inputs'.llm-agents.packages.omp;
      description = "OMP package to install.";
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      description = "Wrapped OMP package actually installed on PATH.";
    };

    settings = mkOption {
      type = yaml.type;
      default = { };
      description = "Settings merged into ~/.omp/agent/config.yml.";
    };

    models = mkOption {
      type = yaml.type;
      default = { };
      description = "Model configuration merged into ~/.omp/agent/models.yml.";
    };
  };

  config = mkIf cfg.enable {
    programs.omp.finalPackage = pkgs.symlinkJoin {
      name = "omp-${cfg.package.version}-browser";
      paths = [ cfg.package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${cfg.package.meta.mainProgram} \
          --set-default PUPPETEER_EXECUTABLE_PATH ${getExe' pkgs.chromium "chromium"} \
          --suffix PATH : ${
            makeBinPath [
              pkgs.python3
              pkgs.ffmpeg-headless
            ]
          }
      '';
      inherit (cfg.package) meta;
    };

    home.packages = [ cfg.finalPackage ];

    programs.omp.settings = {
      tools.approvalMode = "write";

      providers.webSearchOrder = [
        "exa"
        "firecrawl"
      ];
      providers.webSearchExclude = [
        "startpage"
        "duckduckgo"
        "ecosia"
        "google"
        "mojeek"
      ];

      bash = {
        patterns = map (cmd: {
          match = cmd;
          approval = "allow";
        }) llmCfg.allowedBashCommands;
        allowCompoundCommands = true;
        direnv = "auto";
      };
      bashInterceptor.enabled = true;
      checkpoint.enabled = true;

      theme = {
        dark = "dark-catppuccin";
        light = "light-catppuccin";
      };
      symbolPreset = "nerd";
      statusLine = {
        preset = "nerd";
        separator = "powerline-thin";
        contextLine = "embedded";
        compactThinkingLevel = true;
        transparent = true;
        sessionAccent = true;
        showHookStatus = true;
      };
      composer.shape = "band";
      display = {
        shimmer = "classic";
        showTokenUsage = true;
        showTurnTime = true;
        cacheMissMarker = true;
      };
      terminal.showProgress = true;
      tui = {
        mouse = false;
        resizeScrollback = "rebuild";
        vimMode = false;
      };

      defaultThinkingLevel = "xhigh";
      omitThinking = false;
      lsp.formatOnWrite = true;
      read.renderMarkdown = true;
    };

    home.file = mkMerge [
      (
        llmCfg.skills
        |> mapAttrs' (
          name: skill:
          nameValuePair ".omp/agent/skills/${name}" {
            source = skill;
          }
        )
      )
      (
        llmCfg.commands
        |> mapAttrs' (
          name: cmd:
          nameValuePair ".omp/agent/prompts/${name}.md" {
            text = cmd.markdown;
          }
        )
      )
      # The gcm alias drives print mode with `/commit-message`; expose the
      # commit-message skill as a prompt template so the name expands.
      (optionalAttrs (llmCfg.skills ? commit-message) {
        ".omp/agent/prompts/commit-message.md".source = "${llmCfg.skills.commit-message}/SKILL.md";
      })
    ];

    home.activation.ompSettings = hm.dag.entryAfter [ "linkGeneration" ] (
      {
        "config.yml" = cfg.settings;
        "models.yml" = cfg.models;
      }
      |> mapAttrsToList (
        file: settings:
        hm.generators.mkImpureConfigMerger {
          inherit pkgs;
          format = "yaml";
          empty = "{}";
          jqOperation = "$dynamic * $static";
          path = "${config.home.homeDirectory}/.omp/agent/${file}";
          staticSettings = yaml.generate "omp-${file}" settings;
        }
      )
      |> concatStringsSep "\n"
    );

    home.persistence."/persist".directories = [ ".omp" ];
  };
}
