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
              zen-browser.homeModules.beta
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
        {
          user,
          pkgs,
          extraSpecialArgs,
        }:
        (inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;
          modules = [
            (genSharedHomeConfiguration profiles)
            {
              nix = {
                package = pkgs.nix-dram;
                settings = {
                  default-flake = "nixpkgs";
                  experimental-features = [
                    "nix-command"
                    "flakes"
                    "impure-derivations"
                    "pipe-operators"
                  ];
                  substituters = [
                    "https://cache.nixos.org"
                    "https://cache.unlsycn.com:4433"
                  ];
                  trusted-public-keys = [
                    "cache.unlsycn.com-1:beAofQCYfkbHnku0lL7kKzAc1ZCMA4NC3GWqcp5lsio="
                  ];
                };
              };
              home.username = "${user}";
              home.homeDirectory = "/home/${user}";
              programs.home-manager.enable = true;
            }
            {
              # placeholder for impermanence config
              options.home.persistence = with types; mkOption { type = attrsOf raw; };
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
              homeManagerProfiles = [
                "cli"
              ]
              ++ optionals config.isServer [ "server" ]
              ++ optionals config.hasDesktopEnvironment [ "desktop" ]
              ++ optionals config.handheld.enable [ "handheld" ]
              ++ optionals config.environment.persistence."/persist".enable [ "stateless" ];

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
