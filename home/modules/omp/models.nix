{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.omp;
  gateway = config.programs.llm-cli.gateway;
  provider = "senesperejo";

  families = {
    kimi = {
      efforts = [
        "low"
        "high"
        "max"
      ];
      defaultLevel = "max";
      models.kimi-k3 = "Kimi K3";
    };

    grok = {
      efforts = [
        "low"
        "medium"
        "high"
        "xhigh"
      ];
      defaultLevel = "high";
      models."grok-4.7" = "Grok 4.7";
    };

    deepseek = {
      efforts = [
        "low"
        "high"
        "max"
      ];
      defaultLevel = "max";
      models = {
        deepseek-v4-pro = "DeepSeek V4 Pro";
        deepseek-flash = "DeepSeek Flash";
      };
    };

    claude = {
      efforts = [
        "low"
        "medium"
        "high"
        "xhigh"
        "max"
      ];
      defaultLevel = "high";
      models = {
        claude-opus-5-5 = "Claude Opus 5.5";
        claude-sonnet-5-5 = "Claude Sonnet 5.5";
        claude-haiku-5-5 = "Claude Haiku 5.5";
      };
    };

    gpt = {
      api = "openai-responses";
      efforts = [
        "low"
        "medium"
        "high"
        "xhigh"
        "max"
      ];
      defaultLevel = "xhigh";
      models = {
        "gpt-5.6-sol" = "GPT-5.6 Sol";
        "gpt-5.6-luna" = "GPT-5.6 Luna";
        "gpt-5.6-terra" = "GPT-5.6 Terra";
        "gpt-6-astra" = "GPT-6 Astra";
        "gpt-6-luna" = "GPT-6 Luna";
        "gpt-6.1-sol" = "GPT-6.1 Sol";
        "gpt-6-sol" = "GPT-6 Sol";
      };
    };
  };
in
{
  config = mkIf cfg.enable {
    programs.omp.models.providers.${provider} = {
      baseUrl = "${gateway.url}/v1";
      api = "openai-completions";
      models =
        families
        |> mapAttrsToList (
          _: family:
          family.models
          |> mapAttrsToList (
            id: name:
            {
              inherit id name;
              reasoning = true;
              thinking = {
                mode = "effort";
                inherit (family) efforts defaultLevel;
                requiresEffort = true;
              };
            }
            // optionalAttrs (family ? api) { inherit (family) api; }
          )
        )
        |> concatLists;
    }
    // optionalAttrs (gateway.apiKeyFile != null) {
      apiKey = "!${getExe' pkgs.coreutils "cat"} ${gateway.apiKeyFile}";
    };

    programs.omp.settings =
      let
        qualify = model: "${provider}/${model}";
      in
      {
        modelRoles = mapAttrs (_: qualify) {
          default = "kimi-k3";
          slow = "gpt-6-astra";
          plan = "gpt-5.6-sol";
          smol = "deepseek-v4-pro:high";
          tiny = "deepseek-flash:high";
          commit = "deepseek-flash:high";
          task = "grok-4.7:high";
          vision = "gpt-5.6-sol";
          advisor = "gpt-6-astra";
        };

        retry.fallbackChains = mapAttrs (_: map qualify) {
          default = [ "deepseek-v4-pro:max" ];
          task = [
            "gpt-5.6-luna:xhigh"
            "deepseek-v4-pro:max"
          ];
        };
      };
  };
}
