{ inputs, ... }:
{
  imports = [
    inputs.vscode-server.nixosModules.default
  ];
}
