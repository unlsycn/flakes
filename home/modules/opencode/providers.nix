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
    small_model = "deepseek/deepseek-v4-flash";
    enabled_providers = [
      "google"
      "deepseek"
    ];
  };
}
