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
      extraPackages = with pkgs; [
        gcc
        lua-language-server
      ];
    };

    xdg.configFile = {
      "nvim".source = configRepos.nvim.src;
      "nvim-vscode".source = configRepos.nvim-vscode.src;
    };
  };
}
