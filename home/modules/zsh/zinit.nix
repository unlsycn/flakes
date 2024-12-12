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

  zinitModule = submodule {
    options = {
      enable = mkEnableOption ''
        Zinit, A flexible and fast ZSH plugin manager
      '';
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
        description = ''
          "Load rule and list of zinit plugins"
        '';
      };
    };
  };
in
{
  options = {
    programs.zsh.zinit = mkOption {
      type = zinitModule;
      default = { };
      description = "Zinit options";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ zinit ];
  };
}
