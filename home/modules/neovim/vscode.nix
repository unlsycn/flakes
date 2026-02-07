{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  inherit (inputs.nvf.lib.nvim.dag) entryAfter;

  vscodeConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      ./common.nix
      (
        { config, ... }:
        {
          config.vim = {
            theme.enable = false;

            additionalRuntimePaths =
              (map (p: p.package) (attrValues config.vim.extraPlugins))
              ++ (map (p: p.package) (attrValues config.vim.lazy.plugins));

            luaConfigRC.vscode = entryAfter [ "basic" ] ''
              if vim.g.vscode then
                local vscode = require("vscode")
                local map = vim.keymap.set

                -- Windows
                map({"n", "x"}, "<C-w>t", function() vscode.call('workbench.action.terminal.focus') end)
                map({"n", "x"}, "<C-w>e", function() vscode.call('workbench.action.focusSideBar') end)
                map({"n", "x"}, "<C-w>p", function() vscode.call('workbench.action.focusPanel') end)

                -- Actions
                map({"n", "x"}, "gr", function() vscode.call('editor.action.goToReferences') end)
              end
            '';
          };
        }
      )
    ];
  };
  nvim-vscode =
    pkgs.runCommand "nvim-vscode"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${vscodeConfig.neovim}/bin/nvim $out/bin/nvim-vscode
      '';
in
{
  config = mkIf config.programs.nvf.enable {
    home.packages = [
      nvim-vscode
    ];
  };
}
