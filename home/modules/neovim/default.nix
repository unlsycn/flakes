{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  configRepos = pkgs.callPackage ./_sources/generated.nix { };
in
{
  config = mkIf config.programs.neovim.enable {
    programs.neovim = {
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    xdg.configFile = {
      nvim = {
        source = configRepos.nvim.src;
        target = "nvim";
      };
      nvim-vscode = {
        source = configRepos.nvim-vscode.src;
        target = "nvim-vscode";
      };
    };
  };
}
