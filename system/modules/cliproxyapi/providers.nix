{ config, lib, ... }:
with lib;
let
  providers = [
    {
      name = "bigman";
      priority = 10;
      support-prompt-cache-key = true;
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
    }
    {
      name = "shaobing";
      support-prompt-cache-key = true;
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
    }
    {
      name = "deepseek";
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
    }
  ];

  gptThinking = {
    levels = [
      "low"
      "medium"
      "high"
      "xhigh"
    ];
  };
in
{
  config = mkIf config.services.cliproxyapi.enable {
    services.cliproxyapi.settings.openai-compatibility =
      providers
      |> map (provider: {
        inherit (provider) name;
        priority = provider.priority or 0;
        support-prompt-cache-key = provider.support-prompt-cache-key or false;
        base-url = {
          _secret = config.sops.secrets."cliproxyapi-${provider.name}-base-url".path;
        };
        api-key-entries = [
          {
            api-key = {
              _secret = config.sops.secrets."cliproxyapi-${provider.name}-api-key".path;
            };
          }
        ];
        models = provider.models |> map (model: if isAttrs model then model else { name = model; });
      });

    sops.secrets =
      providers
      |> concatMap (provider: [
        "${provider.name}-api-key"
        "${provider.name}-base-url"
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
