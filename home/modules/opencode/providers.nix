{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.opencode;
in
{
  config.programs.opencode.settings = lib.mkIf cfg.enable {
    model = "anthropic-sss/claude-opus-4-6";
    small_model = "anthropic-sss/claude-sonnet-4-6";
    enabled_providers = [
      "google"
      "deepseek"
      "openai-rustcat"
      "openai-sss"
      "anthropic-sss"
    ];
    provider =
      let
        openai_models = {
          "gpt-5-codex" = {
            name = "GPT-5 Codex";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
            };
          };
          "gpt-5.1-codex" = {
            name = "GPT-5.1 Codex";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
            };
          };
          "gpt-5.1-codex-max" = {
            name = "GPT-5.1 Codex Max";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
            };
          };
          "gpt-5.1-codex-mini" = {
            name = "GPT-5.1 Codex Mini";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
            };
          };
          "gpt-5.2" = {
            name = "GPT-5.2";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
              xhigh = { };
            };
          };
          "gpt-5.3-codex-spark" = {
            name = "GPT-5.3 Codex Spark";
            limit = {
              context = 128000;
              output = 32000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
              xhigh = { };
            };
          };
          "gpt-5.3-codex" = {
            name = "GPT-5.3 Codex";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
              xhigh = { };
            };
          };
          "gpt-5.2-codex" = {
            name = "GPT-5.2 Codex";
            limit = {
              context = 400000;
              output = 128000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
              xhigh = { };
            };
          };
          "codex-mini-latest" = {
            name = "Codex Mini";
            limit = {
              context = 200000;
              output = 100000;
            };
            options.store = false;
            variants = {
              low = { };
              medium = { };
              high = { };
            };
          };
        };

        anthropic_models = {
          "claude-opus-4-6" = {
            name = "Claude Opus 4.6";
            limit = {
              context = 1000000;
              output = 128000;
            };
            options.store = false;
            variants = {
              high = { };
              max = { };
            };
          };
          "claude-sonnet-4-6" = {
            name = "Claude Sonnet 4.6";
            limit = {
              context = 1000000;
              output = 64000;
            };
            options.store = false;
            variants = {
              high = { };
              max = { };
            };
          };
        };
      in
      {
        openai-rustcat = {
          npm = "@ai-sdk/openai";
          options = {
            baseURL = "https://rust.cat/v1";
          };
          models = openai_models;
        };
        openai-sss = {
          npm = "@ai-sdk/openai";
          options = {
            baseURL = "https://node-hk.sssaicode.com/api/v1";
          };
          models = openai_models;
        };
        anthropic-sss = {
          npm = "@ai-sdk/anthropic";
          options = {
            baseURL = "https://claude2.sssaicode.com/api/v1";
          };
          models = anthropic_models;
        };
      };
  };
}
