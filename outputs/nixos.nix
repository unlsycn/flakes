{
  self,
  lib,
  withSystem,
  inputs,
  user,
  ...
}:
with builtins;
let
  inherit (inputs.nixpkgs.lib) nixosSystem;
in
{
  flake.nixosConfigurations =
    ../system/hosts
    |> readDir
    |> attrNames
    |> map (
      system:
      ../system/hosts/${system}
      |> readDir
      |> attrNames
      |> map (host: {
        name = host;
        value = withSystem system (
          {
            system,
            inputs',
            pkgs,
            ...
          }:
          with inputs;
          nixosSystem {
            inherit pkgs system;
            specialArgs = {
              inherit
                inputs
                inputs'
                user
                ;
              hostName = host;
            };
            modules = [
              ../system/hosts/${system}/${host}
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              (self.buildConfigurationPhases.genHomeModuleForHost {
                inherit user;
                extraSpecialArgs = {
                  inherit
                    pkgs
                    user
                    inputs
                    inputs'
                    ;
                };
              })
            ];
          }
        );
      })
    )
    |> lib.flatten
    |> listToAttrs;
}
