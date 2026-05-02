{
  bash,
  coreutils,
  fetchFromGitHub,
  findutils,
  gawk,
  git,
  gnugrep,
  gnused,
  jq,
  lib,
  ncurses,
  python3,
  runCommand,
  rsync,
  util-linux,
  writeShellApplication,
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
                export CODEX_HOME="$out/codex-home"
                export HUMANIZE_SRC="$TMPDIR/humanize-src"

                mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$TMPDIR/fake-bin" "$out"

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

                # Install directly into $out so that path hydration
                # ({{HUMANIZE_RUNTIME_ROOT}}) and the bitlesson-selector shim
                # embed the final Nix store path instead of sandbox temporaries.
                ${bash}/bin/bash "$HUMANIZE_SRC/scripts/install-skill.sh" \
                  --repo-root "$HUMANIZE_SRC" \
                  --target codex \
                  --codex-skills-dir "$out/codex-home/skills" \
                  --codex-config-dir "$out/codex-home" \
                  --kimi-skills-dir "$out/codex-home/skills" \
                  --command-bin-dir "$out/bin"
      '';

  runtime = codexInstall + "/codex-home/skills/humanize";

  humanizeWrapper = writeShellApplication {
    name = "humanize";
    runtimeInputs = [
      coreutils
      findutils
      git
      gnugrep
      gnused
      jq
      ncurses
      util-linux
    ];
    excludeShellChecks = [ "SC1091" ];
    text = ''
      source ${runtime}/scripts/humanize.sh
      set +eu
      humanize "$@"
    '';
  };
in
lib.genAttrs [
  "humanize"
  "humanize-gen-plan"
  "humanize-refine-plan"
  "humanize-rlcr"
] (name: codexInstall + "/codex-home/skills/${name}")
// {
  inherit codexInstall src runtime humanizeWrapper;
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
  codexHooksFile = codexInstall + "/codex-home/hooks.json";
  codexConfigToml = codexInstall + "/codex-home/config.toml";
  bitlessonSelector = codexInstall + "/bin/bitlesson-selector";
}
