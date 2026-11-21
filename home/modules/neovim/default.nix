{
  config,
  inputs,
  lib,
  ...
}:
with lib;
{
  imports = [
    inputs.nvf.homeModules.default
    ./cli.nix
    ./vscode.nix
  ];

  config.programs.nvf = mkIf config.programs.nvf.enable {
    defaultEditor = true;
  };
}
