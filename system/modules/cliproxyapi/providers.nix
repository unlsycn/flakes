{ config, lib, ... }:
with lib;
let
  cfg = config.services.cliproxyapi;

  thinking = {
    gpt.levels = [
      "low"
      "medium"
      "high"
      "xhigh"
      "max"
    ];
    claude.levels = [
      "low"
      "medium"
      "high"
      "xhigh"
      "max"
    ];
    kimi.levels = [
      "low"
      "high"
      "max"
    ];
    glm.levels = [
      "low"
      "high"
      "max"
    ];
    qwen.levels = [
      "low"
      "medium"
      "xhigh"
    ];
    grok.levels = [
      "low"
      "medium"
      "high"
      "xhigh"
    ];
    deepseek = {
      levels = [
        "none"
        "low"
        "high"
        "max"
      ];
      zero-allowed = true;
    };
  };

  catalog = {
    "gpt-5.6-sol".thinking = thinking.gpt;
    "gpt-5.6-luna".thinking = thinking.gpt;
    "gpt-5.6-terra".thinking = thinking.gpt;
    "gpt-6-astra".thinking = thinking.gpt;
    "gpt-6-sol".thinking = thinking.gpt;
    "gpt-6-luna".thinking = thinking.gpt;
    "gpt-6.1-sol".thinking = thinking.gpt;
    "claude-opus-5-5".thinking = thinking.claude;
    "claude-sonnet-5-5".thinking = thinking.claude;
    "claude-haiku-5-5".thinking = thinking.claude;
    "grok-4.7".thinking = thinking.grok;
    "deepseek-flash".thinking = thinking.deepseek;
    # DeepSeek V4 Pro is routed to Flash until Pro comes back; clients
    # keep asking for `deepseek-v4-pro` and only this mapping changes.
    "deepseek-v4-pro" = {
      upstream = "deepseek-flash";
      input-modalities = [ "text" ];
      thinking = thinking.deepseek;
    };
  };

  serve = names: genAttrs names (name: catalog.${name});
in
{
  config = mkIf cfg.enable {
    services.cliproxyapi.providers = {
      codex-api-key = {
        bigman = {
          priority = 40;
          models = serve [
            "gpt-5.6-sol"
            "gpt-5.6-luna"
            "gpt-5.6-terra"
            "gpt-6-astra"
            "gpt-6-luna"
            "gpt-6.1-sol"
            "grok-4.7"
            "deepseek-flash"
          ];
        };
        shaobing = {
          enable = false;
          models = serve [
            "gpt-5.6-sol"
            "gpt-5.6-luna"
            "gpt-6-astra"
            "grok-4.7"
            "deepseek-flash"
            "deepseek-v4-pro"
          ];
        };
      };

      openai-compatibility = {
        cat = {
          headers = {
            CF-Access-Client-Id = {
              _secret = config.sops.secrets."cliproxyapi-cat-cf-access-client-id".path;
            };
            CF-Access-Client-Secret = {
              _secret = config.sops.secrets."cliproxyapi-cat-cf-access-client-secret".path;
            };
          };
          models = {
            "kimi-k3.1-pro" = {
              upstream = "kimi-code-cn/k3.1-pro";
              input-modalities = [
                "text"
                "image"
                "video"
              ];
              thinking = thinking.kimi;
            };
            "glm-5.3" = {
              upstream = "zcode/GLM-5.3";
              thinking = thinking.glm;
            };
            "glm-5.3-flash" = {
              upstream = "zcode/GLM-5.3-Flash";
              input-modalities = [
                "text"
                "image"
              ];
              thinking = thinking.glm;
            };
            "qwen-3.8-flash" = {
              upstream = "qoder-cn/qfmodel";
              input-modalities = [
                "text"
                "image"
              ];
              thinking = thinking.qwen;
            };
            "qwen-3.8-max" = {
              upstream = "qoder-cn/qmodel_38max";
              input-modalities = [
                "text"
                "image"
              ];
              thinking = thinking.qwen;
            };
          };
        };
        eba = {
          priority = 10;
          models = serve [
            "gpt-5.6-sol"
            "gpt-5.6-luna"
            "gpt-5.6-terra"
            "gpt-6-astra"
            "gpt-6-sol"
            "gpt-6-luna"
            "gpt-6.1-sol"
            "grok-4.7"
          ];
        };
        deepseek.models = serve [
          "deepseek-flash"
          "deepseek-v4-pro"
        ];
      };

      claude-api-key.eba = {
        priority = 10;
        models = serve [
          "claude-opus-5-5"
          "claude-sonnet-5-5"
          "claude-haiku-5-5"
        ];
      };
    };
  };
}
