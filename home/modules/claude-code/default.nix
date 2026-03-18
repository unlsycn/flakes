{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  llmCfg = config.programs.llm-cli;

  toFrontmatterCommand = _: cmd: ''
    ---
    description: ${cmd.description}
    ---

    ${cmd.prompt}
  '';

  settingsFile = (pkgs.formats.json { }).generate "claude-code-settings.json" (
    config.programs.claude-code.settings
    // {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    }
  );

  statuslineScript = pkgs.writeShellScript "claude-statusline" ''
    input=$(cat)

    read -r MODEL DIR COST PCT DURATION_MS LINES_ADD LINES_DEL < <(echo "$input" | ${getExe pkgs.jq} -r '
      [
        .model.display_name,
        .workspace.current_dir,
        (.cost.total_cost_usd // 0 | tostring),
        (.context_window.used_percentage // 0 | tostring | split(".")[0]),
        (.cost.total_duration_ms // 0 | tostring),
        (.cost.total_lines_added // 0 | tostring),
        (.cost.total_lines_removed // 0 | tostring)
      ] | @tsv
    ')

    CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'

    if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
    elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
    else BAR_COLOR="$GREEN"; fi

    FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
    printf -v FILL "%''${FILLED}s"; printf -v PAD "%''${EMPTY}s"
    BAR="''${FILL// /█}''${PAD// /░}"

    MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

    BRANCH=""
    ${getExe' pkgs.git "git"} rev-parse --git-dir > /dev/null 2>&1 && \
      BRANCH=" ''${DIM}·''${RESET} $(${getExe' pkgs.git "git"} branch --show-current 2>/dev/null)"

    COST_FMT=$(printf '$%.4f' "$COST")

    DIFF=""
    [ "$LINES_ADD" -gt 0 ] || [ "$LINES_DEL" -gt 0 ] && \
      DIFF=" ''${DIM}·''${RESET} ''${GREEN}+''${LINES_ADD}''${RESET}''${RED}-''${LINES_DEL}''${RESET}"

    echo -e "''${CYAN}[$MODEL]''${RESET} ''${DIR##*/}$BRANCH ''${DIM}|''${RESET} ''${BAR_COLOR}''${BAR}''${RESET} ''${PCT}% ''${DIM}|''${RESET} ''${YELLOW}''${COST_FMT}''${RESET} ''${DIM}''${MINS}m''${SECS}s''${RESET}$DIFF"
  '';
in
{
  # Upstream HM module generates ~/.claude/settings.json as a read-only nix store
  # symlink, which prevents Claude Code from persisting runtime changes (permission
  # mode, "always allow", etc.). We override it with a mutable copy that gets reset
  # on each activation. See: github.com/anthropics/claude-code/issues/4808
  config = mkIf config.programs.claude-code.enable {
    programs.claude-code = {
      settings = {
        model = "opus";
        effortLevel = "high";
        statusLine = {
          type = "command";
          command = toString statuslineScript;
        };
        autoMemoryEnabled = true;
        permissions = {
          allow = [
            "Read"
            "WebSearch"
            "WebFetch(domain:github.com)"
            "WebFetch(domain:raw.githubusercontent.com)"
          ]
          ++ (llmCfg.allowedBashCommands |> map (cmd: "Bash(${cmd})"));
          deny = [
            "Read(*.env)"
            "Read(**/.private/**)"
          ];
          ask = [
            "Read(.direnv)"
            "Edit"
            "WebFetch"
          ];
        };
      };
      commands = llmCfg.commands |> mapAttrs toFrontmatterCommand;
    };

    home.file.".claude/settings.json".enable = mkForce false;
    home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      install -Dm644 ${settingsFile} "$HOME/.claude/settings.json"
    '';

    home.persistence."/persist" = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
  };
}
