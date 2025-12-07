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
    programs = {
      git = {
        settings = {
          user.email = "unlsycn@unlsycn.com";
          user.name = "unlsycn";

          init.defaultBranch = "main";
          core.editor = "${nvim}";
          merge.conflictStyle = "diff3";
          log.decorate = "auto";

          alias = {
            amend = "commit --amend";
            fixup = "!f(){ git reset --soft HEAD~\${1} && git commit --amend -C HEAD; };f";
            cm = "commit -m";
            cl = "git commit -c ORIG_HEAD";
            spu = "stash push";
            spo = "stash pop";
            lg = "log --oneline --graph --all";
          };
        };
        signing = {
          signByDefault = true;
          key = null;
        };
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
        };
      };
    };
  };
}
