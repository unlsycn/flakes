{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.codex;
  llmCfg = config.programs.llm-cli;
  maxContext = 320000;
  codexConfigFile = "/.config/codex/config.toml";
in
{
  config = mkIf cfg.enable {
    programs.codex = {
      settings = {
        model_provider = "OpenAI";
        model = "gpt-5.5";
        review_model = "gpt-5.5";
        model_reasoning_effort = "xhigh";
        plan_mode_reasoning_effort = "xhigh";
        model_context_window = maxContext;
        model_auto_compact_token_limit = maxContext * 9 / 10;
        approval_policy = "on-request";
        default_permissions = "default";
        check_for_update_on_startup = false;
        notice.hide_rate_limit_model_nudge = true;
        features.codex_hooks = llmCfg.humanize.enable;
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

    assertions = [
      {
        assertion = config.home.preferXdgDirectories;
        message = "The local Codex mutable config workaround assumes home.preferXdgDirectories = true.";
      }
    ];

    home.activation.codexConfigActivation = hm.dag.entryAfter [ "linkGeneration" ] ''
      configPath=${escapeShellArg "${config.xdg.configHome}/codex/config.toml"}
      mkdir -p "$(dirname -- "$configPath")"

      if [ -e "$configPath" ] || [ -L "$configPath" ]; then
        dynamic="$(${getExe pkgs.yj} -tj < "$configPath" 2>/dev/null || echo '{}')"
      else
        dynamic='{}'
      fi
      static="$(${getExe pkgs.yj} -tj < ${escapeShellArg config.home.file.${codexConfigFile}.source})"
      merged="$(${getExe pkgs.jq} -n '$dynamic * $static' --argjson dynamic "$dynamic" --argjson static "$static")"

      tmp="$(mktemp)"
      printf '%s\n' "$merged" | ${getExe pkgs.yj} -jt > "$tmp"
      if [ -L "$configPath" ]; then
        rm -f "$configPath"
      fi
      install -m 0644 "$tmp" "$configPath"
      rm -f "$tmp"
      unset configPath dynamic static merged tmp
    '';

    home.file = mkMerge [
      {
        ${codexConfigFile}.enable = mkForce false;
      }
      (
        llmCfg.commands
        |> mapAttrs' (
          name: cmd:
          nameValuePair ".config/codex/prompts/${name}.md" {
            text = ''
              ---
              description: ${cmd.description}
              ---

              ${cmd.prompt}
            '';
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
