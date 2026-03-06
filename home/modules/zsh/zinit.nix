{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with types;
let
  cfg = config.programs.zsh.zinit;
in
{
  options.programs.zsh.zinit = mkOption {
    type = submodule {
      options = {
        enable = mkEnableOption "Zinit, A flexible and fast ZSH plugin manager";
        homeDirectory = mkOption {
          type = path;
          default = "${config.home.homeDirectory}/.zinit";
          defaultText = "~/.zinit";
          apply = toString;
          description = "Path to zinit home directory.";
        };
        plugins = mkOption {
          type = attrsOf (coercedTo (either (listOf str) str) toList (listOf str));
          default = { };
          example = literalExpression ''
            {
              "<modifier>" = [ "<repo/plugin> <opt>" ... ];
            }
          '';
          description = "Load rule and list of zinit plugins";
        };
      };
    };
    default = { };
    description = "Zinit options";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.zinit ];
    programs.zsh.initContent =
      optionalString cfg.enable ''
        declare -A ZINIT
        ZINIT_HOME=${cfg.homeDirectory}
        ZINIT[HOME_DIR]=''${ZINIT_HOME}
        [[ -r ''${ZINIT_HOME} ]] || mkdir -p ''${ZINIT_HOME}
        source "${pkgs.zinit}/share/zinit/zinit.zsh"&>/dev/null
        ln -sf "${pkgs.zinit}/share/zsh/site-functions/_zinit" ''${ZINIT_HOME}/completions
        (( ''${+_comps} )) && _comps[zinit]="${pkgs.zinit}/share/zsh/site-functions/_zinit"

        ${optionalString (cfg.plugins != { }) ''
          ${
            cfg.plugins
            |> mapAttrsToList (
              modifier: plugins: "zinit ${modifier} for \\\n ${plugins |> intersperse " \\\n " |> concatStrings}"
            )
            |> concatMapStrings (x: x + "\n")
          }
        ''}
      ''
      |> lib.mkOrder 550;
  };
}
