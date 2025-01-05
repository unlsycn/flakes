{
  pkgs,
  inputs,
  system,
  user,
}:
with inputs;
with builtins;
let
  inherit (nixpkgs.lib) nixosSystem;
  hostList = ../system/hosts |> readDir |> attrNames;
in
hostList
|> map (host: {
  name = host;
  value = nixosSystem {
    inherit pkgs system;
    specialArgs = {
      inherit inputs user system;
      hostName = host;
    };
    modules = [
      ../system/hosts/${host}
      impermanence.nixosModules.impermanence
      sops-nix.nixosModules.sops
    ];
  };
})
|> listToAttrs
