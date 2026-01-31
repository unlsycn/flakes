{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.programs.llm-cli;
in
{
  options.programs.llm-cli = {
    enable = lib.mkEnableOption "llm-cli";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gemini-cli-bin;
      description = "The package to use for llm-cli";
    };

  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    persist."/persist".users.${user}.directories = [
      ".gemini"
    ];
  };
}
