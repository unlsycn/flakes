{
  lib,
  inputs,
  withSystem,
  user,
  ...
}:
with inputs;
with builtins;
with lib;
let
  inherit (inputs.nixpkgs.lib) nixosSystem;
in
{
  flake = {
    nixosModules =
      ./modules
      |> readDir
      |> filterAttrs (name: type: type == "directory")
      |> mapAttrs (module: _: ./modules/${module});

    buildConfigurationPhases = {
      genNixosConfiguration = system: host: {
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
            modules = attrValues self.nixosModules ++ [
              ../system/hosts/${system}/${host}
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager
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
      };
    };
  };
}
