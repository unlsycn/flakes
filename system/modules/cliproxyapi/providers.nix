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

  kimiThinking = {
    levels = [
      "low"
      "high"
      "max"
    ];
  };

  grokThinking = {
    levels = [
      "low"
      "medium"
      "high"
      "xhigh"
    ];
  };

  deepseekThinking = {
    levels = [
      "none"
      "low"
      "high"
      "max"
    ];
    zero-allowed = true;
  };

  # DeepSeek V4 Pro is routed to Flash until Pro comes back; clients
  # keep asking for `deepseek-v4-pro` and only this mapping changes.
  dsV4Pro = {
    name = "deepseek-flash";
    alias = "deepseek-v4-pro";
    input-modalities = [ "text" ];
    thinking = deepseekThinking;
  };
in
{
  config = mkIf cfg.enable {
    services.cliproxyapi.providers = {
      codex-api-key = {
        bigman = {
          priority = 40;
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
              name = "gpt-5.6-terra";
              thinking = gptThinking;
            }
            {
              name = "gpt-6-astra";
              thinking = gptThinking;
            }
            {
              name = "gpt-6-luna";
              thinking = gptThinking;
            }
            {
              name = "gpt-6.1-sol";
              thinking = gptThinking;
            }
            {
              name = "grok-4.7";
              thinking = grokThinking;
            }
            {
              name = "deepseek-flash";
              thinking = deepseekThinking;
            }
          ];
        };
        shaobing = {
          # Upstream answers 401 `user_disabled` for this key, so every request
          # that fell back to it burned a retry round and a cooldown wait.
          # Kept configured (models + secrets) so it is a one-line flip back.
          enable = false;
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
            {
              name = "grok-4.6";
              thinking = grokThinking;
            }
          ];
        };
      };

      openai-compatibility = {
        bigman = {
          priority = 40;
          models = [
            {
              name = "k3";
              alias = "kimi-k3";
              thinking = kimiThinking;
            }
          ];
        };
        shaobing = {
          models = [
            {
              name = "deepseek-flash";
              thinking = deepseekThinking;
            }
            dsV4Pro
          ];
        };
        deepseek = {
          models = [
            dsV4Pro
            {
              name = "deepseek-flash";
              thinking = deepseekThinking;
            }
          ];
        };
      };
    };

    services.cliproxyapi.settings = {
      codex-api-key =
        cfg.providers.codex-api-key
        |> mapAttrsToList (
          name: provider:
          {
            inherit (provider) models priority;
            base-url._secret = config.sops.secrets."cliproxyapi-${name}-base-url".path;
            api-key._secret = config.sops.secrets."cliproxyapi-${name}-api-key".path;
          }
          // optionalAttrs (!provider.enable) {
            excluded-models = [ "*" ];
          }
        );

      openai-compatibility =
        cfg.providers.openai-compatibility
        |> mapAttrsToList (
          name: provider:
          {
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
          // optionalAttrs (!provider.enable) {
            disabled = true;
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
      |> unique
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
