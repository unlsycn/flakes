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

  mutableFile = import ../../lib { inherit lib pkgs; };

  configFile = yaml.generate "omp-config.yml" cfg.settings;

  apiKey = optionalAttrs config.sops.control.deploySecrets {
    apiKey = "!${getExe' pkgs.coreutils "cat"} ${config.sops.secrets.senesperejo-client-key.path}";
  };

  wrappedOmp = pkgs.symlinkJoin {
    name = "omp-${cfg.package.version}-browser";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${cfg.package.meta.mainProgram} \
        --set-default PUPPETEER_EXECUTABLE_PATH ${getExe' pkgs.chromium "chromium"}
    '';
    inherit (cfg.package) meta;
  };

  reasoningModel = efforts: defaultLevel: {
    reasoning = true;
    thinking = {
      mode = "effort";
      inherit efforts defaultLevel;
      requiresEffort = true;
    };
  };

  standardEfforts = reasoningModel [ "low" "high" "max" ] "max";
  gptEfforts = reasoningModel [ "low" "medium" "high" "xhigh" "max" ] "xhigh";

  modelsFile = yaml.generate "omp-models.yml" {
    providers = {
      senesperejo = {
        baseUrl = "https://llm.ts.unlsycn.com/v1";
        api = "openai-completions";
        models = [
          (
            {
              id = "kimi-k3";
              name = "Kimi K3";
            }
            // standardEfforts
          )
          (
            {
              id = "grok-4.6";
              name = "Grok 4.6";
            }
            // reasoningModel [ "low" "medium" "high" "xhigh" ] "high"
          )
          (
            {
              id = "deepseek-v4-pro";
              name = "DeepSeek V4 Pro";
            }
            // standardEfforts
          )
          (
            {
              id = "deepseek-flash";
              name = "DeepSeek Flash";
            }
            // standardEfforts
          )
        ];
      }
      // apiKey;

      "senesperejo-codex" = {
        baseUrl = "https://llm.ts.unlsycn.com/v1";
        api = "openai-responses";
        models = [
          (
            {
              id = "gpt-5.6-sol";
              name = "GPT-5.6 Sol";
            }
            // gptEfforts
          )
          (
            {
              id = "gpt-5.6-luna";
              name = "GPT-5.6 Luna";
            }
            // gptEfforts
          )
          (
            {
              id = "gpt-6-astra";
              name = "GPT-6 Astra";
            }
            // gptEfforts
          )
        ];
      }
      // apiKey;
    };
  };

  mutableOmpConfig = mutableFile.mkMutableGeneratedFile {
    inherit config;
    targetPath = "${config.home.homeDirectory}/.omp/agent/config.yml";
    homeFilePath = ".omp/agent/config.yml";
    format = "yaml";
  };

  mutableOmpModels = mutableFile.mkMutableGeneratedFile {
    inherit config;
    targetPath = "${config.home.homeDirectory}/.omp/agent/models.yml";
    homeFilePath = ".omp/agent/models.yml";
    format = "yaml";
  };
in
{
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
      description = "Settings rendered to ~/.omp/agent/config.yml.";
    };
  };

  config = mkIf cfg.enable {
    programs.omp.finalPackage = wrappedOmp;
    home.packages = [ cfg.finalPackage ];

    programs.omp.settings = {
      modelRoles = {
        default = "senesperejo/kimi-k3";
        slow = "senesperejo-codex/gpt-6-astra";
        plan = "senesperejo-codex/gpt-5.6-sol";
        smol = "senesperejo/deepseek-v4-pro:high";
        tiny = "senesperejo/deepseek-flash:high";
        commit = "senesperejo/deepseek-flash:high";
        task = "senesperejo/grok-4.6";
        vision = "senesperejo-codex/gpt-5.6-sol";
        advisor = "senesperejo-codex/gpt-6-astra";
      };

      retry.fallbackChains = {
        default = [ "senesperejo/deepseek-v4-pro:max" ];
        task = [
          "senesperejo-codex/gpt-5.6-luna:xhigh"
          "senesperejo/deepseek-v4-pro:max"
        ];
      };

      tools.approvalMode = "write";

      # Exa's public MCP and Firecrawl's keyless mode answer without any
      # credential, but only when explicitly listed; every credential-free
      # scraper behind them is gated on the egress IP (DuckDuckGo and Google
      # detect the datacenter range, Ecosia sits behind Cloudflare, Mojeek
      # refuses the connection at all), and each one costs a full provider
      # timeout before the chain gives up.
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
        vimMode = true;
      };

      defaultThinkingLevel = "xhigh";
      omitThinking = false;
      lsp.formatOnWrite = true;
      read.renderMarkdown = true;
    };

    home.file = mkMerge [
      {
        ".omp/agent/config.yml".source = configFile;
        ".omp/agent/models.yml".source = modelsFile;
      }
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
            text = ''
              ---
              description: ${cmd.description}
              ---

              ${cmd.prompt}
            '';
          }
        )
      )
      # The gcm alias drives print mode with `/commit-message`; expose the
      # commit-message skill as a prompt template so the name expands.
      (optionalAttrs (llmCfg.skills ? commit-message) {
        ".omp/agent/prompts/commit-message.md".source = "${llmCfg.skills.commit-message}/SKILL.md";
      })
      mutableOmpConfig.homeFile
      mutableOmpModels.homeFile
    ];

    home.activation = {
      ompConfigActivation = mutableOmpConfig.activation;
      ompModelsActivation = mutableOmpModels.activation;
    };

    home.persistence."/persist".directories = [ ".omp" ];
  };
}
