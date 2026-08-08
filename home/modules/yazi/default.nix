{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.programs.yazi.enable {
    programs.yazi = {
      shellWrapperName = "yy";

      settings = {
        mgr.sort_by = "natural";

        plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
      };

      plugins.git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
      };
    };
  };
}
