{
  config,
  lib,
  pkgs,
  ...
}:
let
  nvim = lib.getExe pkgs.neovim;
in
{
  config = lib.mkIf config.programs.git.enable {
    programs.git = {
      userEmail = "unlsycn@unlsycn.com";
      userName = "unlsycn";

      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
        };
      };

      signing = {
        signByDefault = true;
        key = null;
      };

      aliases = {
        amend = "commit --amend";
        fixup = "!f(){ git reset --soft HEAD~\${1} && git commit --amend -C HEAD; };f";
        cm = "commit -m";
        spu = "stash push";
        spo = "stash pop";
      };

      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "${nvim}";
        merge.conflictStyle = "diff3";
      };
    };
  };
}
