{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
with lib;
let
  cfg = config.programs.codex;
  llmCfg = config.programs.llm-cli;
  maxContext = 640000;
in
{
  config = mkIf cfg.enable {
    programs.codex = {
      package =
        let
          codex = inputs'.llm-agents.packages.codex;
        in
        mkIf (llmCfg.gateway.apiKeyFile != null) (
          pkgs.runCommand "codex-${codex.version}"
            {
              inherit (codex) meta;
              nativeBuildInputs = [ pkgs.makeWrapper ];
            }
            ''
              makeWrapper ${getExe codex} $out/bin/codex \
                --run 'export SENESEPEREJO_KEY="$(cat ${llmCfg.gateway.apiKeyFile})"'
            ''
        );
      mutableSettings = true;
      settings = {
        model = "gpt-5.6-sol";
        review_model = "gpt-5.6-sol";
        model_reasoning_effort = "xhigh";
        plan_mode_reasoning_effort = "xhigh";
        model_context_window = maxContext;
        model_auto_compact_token_limit = maxContext * 9 / 10;
        approval_policy = "on-request";
        default_permissions = "default";
        check_for_update_on_startup = false;
        notice.hide_rate_limit_model_nudge = true;
        features.hooks = llmCfg.humanize.enable;
        project_doc_fallback_filenames = filter (name: name != "AGENTS.md") llmCfg.projectInstructions;
        features.multi_agent = true;

        permissions.default.filesystem = {
          ":minimal" = "read";
          ":project_roots" = {
            "." = "read";
            ".private" = "none";
            ".env" = "none";
          };
        };

        permissions.yolo.filesystem = {
          ":minimal" = "read";
          ":project_roots" = {
            "." = "write";
            ".private" = "none";
            ".env" = "none";
          };
        };

        permissions.yolo.network = {
          enabled = true;
          mode = "full";
          allowed_domains = [ "*" ];
          allow_local_binding = false;
        };
      }
      // optionalAttrs (llmCfg.gateway.apiKeyFile != null) {
        model_provider = "senesperejo";
        model_providers."senesperejo" = {
          name = "senesperejo";
          base_url = "${llmCfg.gateway.url}/v1";
          env_key = "SENESEPEREJO_KEY";
          wire_api = "responses";
        };
      };
    };

    home.file = mkMerge [
      (
        llmCfg.commands
        |> mapAttrs' (
          name: cmd:
          nameValuePair ".config/codex/prompts/${name}.md" {
            text = cmd.markdown;
          }
        )
      )
      (
        (llmCfg.skills // llmCfg.codexSkills)
        |> mapAttrs' (
          name: content:
          # Work around https://github.com/openai/codex/issues/10470.
          nameValuePair ".agents/skills/${name}" {
            source = content;
          }
        )
      )
      (optionalAttrs llmCfg.humanize.enable {
        ".config/codex/hooks.json".source = pkgs.humanize.codexHooksFile;
        ".config/humanize/config.json".source = (pkgs.formats.json { }).generate "humanize-config.json" (
          {
            bitlesson_model = cfg.settings.model;
            codex_model = cfg.settings.model;
            codex_effort = cfg.settings.model_reasoning_effort;
          }
          // optionalAttrs (!config.programs.claude-code.enable) {
            provider_mode = "codex-only";
          }
        );
      })
    ];

    home.persistence."/persist".directories = [ ".config/codex" ];
  };
}
