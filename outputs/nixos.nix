{
  self,
  withSystem,
  inputs,
  user,
  ...
}:
with builtins;
let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  hostList = ../system/hosts |> readDir |> attrNames;
in
{
  flake.nixosConfigurations =
    hostList
    |> map (host: {
      name = host;
      value = withSystem "x86_64-linux" (
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
            ../system/hosts/${host}
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
    |> listToAttrs;
}
