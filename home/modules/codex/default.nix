{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.codex;
  llmCfg = config.programs.llm-cli;

  toPrompt = _: cmd: ''
    ---
    description: ${cmd.description}
    ---

    ${cmd.prompt}
  '';
in
{
  config = mkIf cfg.enable {
    programs.codex = {
      settings = {
        model_provider = "OpenAI";
        model = "gpt-5.4";
        review_model = "gpt-5.4";
        model_reasoning_effort = "high";
        plan_mode_reasoning_effort = "xhigh";
        model_context_window = 1000000;
        model_auto_compact_token_limit = 900000;
        approval_policy = "on-request";
        default_permissions = "default";
        check_for_update_on_startup = false;
        notice.hide_rate_limit_model_nudge = true;
        project_doc_fallback_filenames = filter (name: name != "AGENTS.md") llmCfg.projectInstructions;
        features.multi_agent = true;
        model_providers.OpenAI = {
          name = "OpenAI";
          base_url = "https://rust.cat";
          wire_api = "responses";
          requires_openai_auth = true;
        };

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
      };
    };

    home.file =
      (
        llmCfg.commands
        |> mapAttrs' (
          name: cmd:
          nameValuePair ".config/codex/prompts/${name}.md" {
            text = toPrompt name cmd;
          }
        )
      )
      // (
        llmCfg.skills
        |> mapAttrs' (
          name: content:
          # Work around https://github.com/openai/codex/issues/10470.
          nameValuePair ".agents/skills/${name}" {
            source = content;
          }
        )
      );

    home.persistence."/persist".directories = [ ".config/codex" ];
  };
}
