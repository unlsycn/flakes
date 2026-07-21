{
  bat,
  coreutils,
  fzf,
  ripgrep,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "rgfzf";
  runtimeInputs = [
    bat
    coreutils
    fzf
    ripgrep
  ];
  text = ''
    stateDirectory=$(mktemp -d "''${TMPDIR:-/tmp}/rgfzf.XXXXXX")
    trap 'rm -rf "$stateDirectory"' EXIT

    ripgrepQuery="$stateDirectory/ripgrep-query"
    fzfQuery="$stateDirectory/fzf-query"
    ripgrepPrefix="rg --column --line-number --no-heading --color=always --smart-case"
    initialQuery="$*"
    editor="''${EDITOR:-nvim}"

    fzf --ansi --disabled --query "$initialQuery" \
      --bind "start:reload:$ripgrepPrefix {q}" \
      --bind "change:reload:sleep 0.1; $ripgrepPrefix {q} || true" \
      --bind "ctrl-t:transform:[[ ! \$FZF_PROMPT =~ ripgrep ]] &&
          echo \"rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \\{q} > $fzfQuery; cat $ripgrepQuery\" ||
          echo \"unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \\{q} > $ripgrepQuery; cat $fzfQuery\"" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt "1. ripgrep> " \
      --delimiter : \
      --header "CTRL-T: Switch between ripgrep/fzf" \
      --preview "bat --color=always {1} --highlight-line {2}" \
      --preview-window "up,60%,border-bottom,+{2}+3/3,~3" \
      --bind "enter:become($editor {1} +{2})"
  '';
}
