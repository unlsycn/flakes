{ config, lib, ... }:
with lib;
let
  cfg = config.services.cliproxyapi;

  gptThinking = {
    levels = [
      "low"
      "medium"
      "high"
      "xhigh"
      "max"
    ];
  };
in
{
  config = mkIf cfg.enable {
    services.cliproxyapi.providers = {
      codex-api-key = {
        bigman = {
          priority = 10;
          models = [
            {
              name = "gpt-5.6-sol";
              thinking = gptThinking;
            }
            {
              name = "gpt-6-astra";
              thinking = gptThinking;
            }
          ];
        };
        shaobing = {
          models = [
            {
              name = "gpt-5.6-sol";
              thinking = gptThinking;
            }
            {
              name = "gpt-5.6-luna";
              thinking = gptThinking;
            }
            {
              name = "gpt-6-astra";
              thinking = gptThinking;
            }
          ];
        };
      };

      openai-compatibility = {
        deepseek = {
          models = [
            {
              name = "deepseek-v4-pro";
              input-modalities = [ "text" ];
            }
            {
              name = "deepseek-flash";
              input-modalities = [ "text" ];
            }
          ];
        };
      };
    };

    services.cliproxyapi.settings = {
      codex-api-key =
        cfg.providers.codex-api-key
        |> mapAttrsToList (
          name: provider: {
            inherit (provider) models priority;
            base-url._secret = config.sops.secrets."cliproxyapi-${name}-base-url".path;
            api-key._secret = config.sops.secrets."cliproxyapi-${name}-api-key".path;
          }
        );

      openai-compatibility =
        cfg.providers.openai-compatibility
        |> mapAttrsToList (
          name: provider: {
            inherit (provider) models priority support-prompt-cache-key;
            inherit name;
            headers = {
              "User-Agent" = "$User-Agent";
              Originator = "$originator";
              X-Codex-Window-Id = "$x-codex-window-id";
              X-Codex-Turn-Metadata = "$x-codex-turn-metadata";
              X-Codex-Installation-Id = "$x-codex-installation-id";
            };
            base-url._secret = config.sops.secrets."cliproxyapi-${name}-base-url".path;
            api-key-entries = [
              {
                api-key._secret = config.sops.secrets."cliproxyapi-${name}-api-key".path;
              }
            ];
          }
        );
    };

    sops.secrets =
      cfg.providers
      |> attrValues
      |> concatMap attrNames
      |> concatMap (name: [
        "${name}-api-key"
        "${name}-base-url"
      ])
      |> map (
        key:
        nameValuePair "cliproxyapi-${key}" {
          sopsFile = ./secrets.yaml;
          inherit key;
          restartUnits = [ "cliproxyapi.service" ];
        }
      )
      |> listToAttrs;
  };
}
