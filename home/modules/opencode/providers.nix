{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.opencode;

  # Cap context window to avoid performance degradation at very long contexts.
  maxContext = 256000;
  capContext = limit: limit // { context = lib.min limit.context maxContext; };
in
{
  config.programs.opencode.settings = lib.mkIf cfg.enable {
    model = "deepseek/deepseek-v4-pro";
    small_model = "deepseek/deepseek-flash";
    enabled_providers = [
      "google"
      "deepseek"
      "senesperejo"
    ];
    provider."senesperejo" = {
      npm = "@ai-sdk/openai-compatible";
      name = "senesperejo";
      options = {
        baseURL = "https://llm.ts.unlsycn.com/v1";
      }
      // lib.optionalAttrs config.sops.control.deploySecrets {
        apiKey = "{file:${config.sops.secrets.senesperejo-client-key.path}}";
      };
      models = {
        "gpt-5.6-sol" = {
          name = "GPT-5.6 Sol";
        };
        "gpt-6-astra" = {
          name = "GPT-6 Astra";
        };
        "deepseek-v4-pro" = {
          name = "DeepSeek V4 Pro";
        };
        "deepseek-flash" = {
          name = "DeepSeek Flash";
        };
      };
    };
  };
}
