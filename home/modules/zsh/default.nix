{
  config,
  lib,
  pkgs,
  user,
  ...
}:
with lib;
let
  zinitConfig = config.programs.zsh.zinit;
  zinitInit = optionalString zinitConfig.enable ''
    declare -A ZINIT
    ZINIT_HOME=${zinitConfig.homeDirectory}
    ZINIT[HOME_DIR]=''${ZINIT_HOME}
    [[ -r ''${ZINIT_HOME} ]] || mkdir -p ''${ZINIT_HOME}
    source "${pkgs.zinit}/share/zinit/zinit.zsh"&>/dev/null
    ln -sf "${pkgs.zinit}/share/zsh/site-functions/_zinit" ''${ZINIT_HOME}/completions
    (( ''${+_comps} )) && _comps[zinit]="${pkgs.zinit}/share/zsh/site-functions/_zinit"

    ${optionalString (zinitConfig.plugins != { }) ''
      ${concatMapStrings (x: x + "\n") (
        mapAttrsToList (
          modifier: plugins: "zinit ${modifier} for \\\n  ${concatStrings (intersperse " \\\n  " plugins)}"
        ) zinitConfig.plugins
      )}
    ''}
  '';

  icdiff = "${pkgs.icdiff}/bin/icdiff";
  zellij = "${pkgs.zellij}/bin/zellij";
  nnn = "${pkgs.nnn}/bin/nnn";
in
{
  imports = [ ./zinit.nix ];

  config = mkIf config.programs.zsh.enable {
    programs.zsh = {
      autosuggestion.enable = false;
      enableCompletion = false;
      autocd = true;

      history = {
        ignoreDups = true;
        ignorePatterns = [
          "builtin cd *"
          "cd *"
          "history *"
          "ls *"
        ];

        save = 10000;
        size = 10000;

        extended = true;
        share = true;
        append = true;
      };

      shellAliases = {
        "history" = "history 0";
        "ll" = "ls -l";
        "la" = "ls -A";
        "lla" = "ls -Al";
        "l" = "ls -CF";
        "diff" = icdiff;
        "n" = nnn;
        "dev" = "${zellij} a dev || ${zellij} -s dev";
        "cdtmp" = "cd `mktemp -d`";
        "pastebin" = "curl -F \"c=@-\" \"http://fars.ee/\"";
      };

      zinit = {
        enable = true;
        homeDirectory = "${config.home.homeDirectory}/.local/share/zinit";
        plugins = {
          "depth=1 atload'source \"''\${HOME}/.p10k.zsh\"' light-mode" = [ "romkatv/powerlevel10k" ];
          "lucid blockf depth=1 light-mode" = [
            "jeffreytse/zsh-vi-mode"
            "paulirish/git-open"
            "zsh-users/zsh-autosuggestions"
          ];
          "lucid light-mode" = [ "OMZ::plugins/extract/extract.plugin.zsh" ];
          "lucid depth=1 light-mode has'doas'" = [ "Senderman/doas-zsh-plugin" ];
          "lucid has'sudo'" = [ "OMZ::plugins/sudo/sudo.plugin.zsh" ];
          "lucid depth=1 light-mode" = [ "Aloxaf/fzf-tab" ];
          "wait'!1a' lucid blockf depth=1 atload'zicompinit' light-mode" = [
            "zdharma-continuum/fast-syntax-highlighting"
          ];
        };
      };

      initExtraFirst = ''
        (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
        P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
        [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
        (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
      '';

      initExtraBeforeCompInit = ''
        ${zinitInit}
      '';

      initExtra = ''
        compinit -d ~/.cache/zcompdump
        zstyle ':completion:*:*:*:*:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

        ZVM_VI_INSERT_ESCAPE_BINDKEY="jk"
        ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
        ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
        ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK

        setopt interactivecomments # allow comments in interactive mode
        setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
        setopt nonomatch           # hide error message if there is no match for the pattern
        setopt notify              # report the status of background jobs immediately
        setopt numericglobsort     # sort filenames numerically when it makes sense
        setopt promptsubst         # enable command substitution in prompt

        # configure `time` format
        TIMEFMT=$'real\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

        # Take advantage of $LS_COLORS for completion as well
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

        # Remove path separator from WORDCHARS.
        WORDCHARS=''${WORDCHARS//\/}
      '';
    };

    home.file.".p10k.zsh" = {
      source = ./.p10k.zsh;
    };

    persist."/persist".users.${user} = {
      files = [ ".zsh_history" ];
    };
  };
}
