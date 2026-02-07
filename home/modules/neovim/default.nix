{
  config,
  inputs,
  lib,
  ...
}:
with lib;
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./cli.nix
    ./vscode.nix
  ];

  config.programs.nvf = mkIf config.programs.nvf.enable {
    defaultEditor = true;
  };
}
