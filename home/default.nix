{
  self,
  lib,
  inputs,
  ...
}:
with inputs;
with builtins;
with lib;
{
  flake = {
    homeModules =
      ./modules
      |> readDir
      |> filterAttrs (name: type: type == "directory")
      |> mapAttrs (module: _: ./modules/${module});

    buildConfigurationPhases = rec {
      genSharedHomeConfiguration =
        let
          profileList = ./profiles |> readDir |> attrNames;
        in
        profiles: {
          imports =
            (profileList |> map (profile: ./profiles/${profile}))
            ++ attrValues self.homeModules
            ++ [
              vscode-server.homeModules.default
              sops-nix.homeManagerModules.sops
            ];

          profile =
            profileList
            |> map (profile: {
              name = "${profile}";
              value = {
                enable = builtins.elem "${profile}" profiles;
              };
            })
            |> listToAttrs;

          home.stateVersion = "24.05"; # Dont touch it
        };

      genHomeConfigurationForStandalone =
        profiles:
        { user, pkgs }:
        (inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (genSharedHomeConfiguration profiles)
            {
              nix.package = pkgs.nix;
              home.username = "${user}";
              home.homeDirectory = "/home/${user}";
              programs.home-manager.enable = true;
            }
          ];
        });

      genHomeModuleForHost =
        { user, extraSpecialArgs }:
        (
          { config, lib, ... }:
          with lib;
          {
            options.homeManagerProfiles = mkOption {
              type = with types; listOf str;
              description = "Home Manager profiles to enable";
            };

            config = {
              home-manager = {
                users.${user} = genSharedHomeConfiguration config.homeManagerProfiles;
                useGlobalPkgs = true;
                useUserPackages = true;
                inherit extraSpecialArgs;
              };
            };
          }
        );

    };
  };
}
