{
  bash,
  coreutils,
  fetchFromGitHub,
  gawk,
  gnused,
  jq,
  lib,
  python3,
  runCommand,
  rsync,
  ...
}:
let
  src = fetchFromGitHub {
    owner = "PolyArch";
    repo = "humanize";
    rev = "179a87c6753fb9a804251668af6bd824439fdb9e";
    hash = "sha256-sIhXInq5/EIE8CGfW2btK2LmWRiO7v8U9IaM55XPZAA=";
  };

  codexInstall =
    runCommand "humanize-codex-install"
      {
        nativeBuildInputs = [
          bash
          coreutils
          gawk
          gnused
          jq
          python3
          rsync
        ];
      }
      ''
                export HOME="$TMPDIR/home"
                export XDG_CONFIG_HOME="$TMPDIR/xdg-config"
                export CODEX_HOME="$TMPDIR/codex-home"
                export HUMANIZE_COMMAND_BIN_DIR="$TMPDIR/bin"
                export HUMANIZE_SRC="$TMPDIR/humanize-src"

                mkdir -p \
                  "$HOME" \
                  "$XDG_CONFIG_HOME" \
                  "$CODEX_HOME" \
                  "$HUMANIZE_COMMAND_BIN_DIR" \
                  "$TMPDIR/fake-bin" \
                  "$out"

                cp -r ${src} "$HUMANIZE_SRC"
                chmod -R u+w "$HUMANIZE_SRC"
                patchShebangs "$HUMANIZE_SRC/scripts" "$HUMANIZE_SRC/hooks"

                cat > "$TMPDIR/fake-bin/codex" <<EOF
        #!${bash}/bin/bash
        set -euo pipefail

        case "\''${1:-} \''${2:-} \''${3:-}" in
          "features list ")
            cat <<'LIST'
        codex_hooks                      under development  false
        LIST
            ;;
          "features enable codex_hooks")
            mkdir -p "\''${CODEX_HOME:?}"
            cat > "\''${CODEX_HOME}/config.toml" <<'TOML'
        [features]
        codex_hooks = true
        TOML
            ;;
          *)
            echo "unexpected fake codex invocation: \$*" >&2
            exit 1
            ;;
        esac
        EOF
                chmod +x "$TMPDIR/fake-bin/codex"

                export PATH="$TMPDIR/fake-bin:$PATH"

                ${bash}/bin/bash "$HUMANIZE_SRC/scripts/install-skill.sh" \
                  --repo-root "$HUMANIZE_SRC" \
                  --target codex \
                  --codex-skills-dir "$CODEX_HOME/skills" \
                  --codex-config-dir "$CODEX_HOME" \
                  --command-bin-dir "$HUMANIZE_COMMAND_BIN_DIR"

                mkdir -p "$out/codex-home" "$out/xdg-config" "$out/bin"
                cp -r "$CODEX_HOME"/. "$out/codex-home/"
                cp -r "$XDG_CONFIG_HOME"/. "$out/xdg-config/"
                cp -r "$HUMANIZE_COMMAND_BIN_DIR"/. "$out/bin/"

                ${bash}/bin/bash "$HUMANIZE_SRC/scripts/install-codex-hooks.sh" \
                  --codex-config-dir "$out/codex-home" \
                  --runtime-root "$out/codex-home/skills/humanize" \
                  --skip-enable-feature
      '';
in
lib.genAttrs [
  "humanize"
  "humanize-gen-plan"
  "humanize-refine-plan"
  "humanize-rlcr"
] (name: codexInstall + "/codex-home/skills/${name}")
// {
  inherit codexInstall src;
  claudePlugin =
    runCommand "humanize-claude-plugin"
      {
        nativeBuildInputs = [
          bash
          coreutils
          rsync
        ];
      }
      ''
        cp -r ${src} "$out"
        chmod -R u+w "$out"
        patchShebangs "$out/scripts" "$out/hooks"
      '';
  runtime = codexInstall + "/codex-home/skills/humanize";
  codexHooksFile = codexInstall + "/codex-home/hooks.json";
  codexConfigToml = codexInstall + "/codex-home/config.toml";
  bitlessonSelector = codexInstall + "/bin/bitlesson-selector";
}
