{
  pkgs,
  inputs,
  system,
  user,
}:
with inputs;
let
  inherit (nixpkgs.lib) nixosSystem;
  hostList = builtins.attrNames (builtins.readDir ../system/hosts);
in
builtins.listToAttrs (
  builtins.map (host: {
    name = host;
    value = nixosSystem {
      inherit pkgs system;
      specialArgs = {
        inherit inputs user;
        hostName = host;
      };
      modules = [
        ../system/hosts/${host}
      ];
    };
  }) hostList
)
