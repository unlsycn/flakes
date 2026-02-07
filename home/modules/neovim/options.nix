{
  config,
  lib,
  ...
}:
with lib;
{
  options.vim = {
    lazy.plugins = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.globals = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "Globals to define for this plugin, merged into vim.globals.";
          };
        }
      );
    };

    extraPlugins = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.globals = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "Globals to define for this plugin, merged into vim.globals.";
          };
        }
      );
    };
  };

  config = {
    vim.globals = mkMerge (
      (mapAttrsToList (_: plugin: plugin.globals) config.vim.lazy.plugins)
      ++ (mapAttrsToList (_: plugin: plugin.globals) config.vim.extraPlugins)
    );
  };
}
