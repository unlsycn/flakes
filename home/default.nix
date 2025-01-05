{
  lib,
  inputs,
  inputs',
  user,
  profiles,
  ...
}:
with builtins;
with inputs;
let
  profileList = ./profiles |> readDir |> attrNames;
in
{
  users.${user} = {
    imports =
      (profileList |> map (profile: ./profiles/${profile}))
      ++ (
        ./modules
        |> lib.filesystem.listFilesRecursive
        |> lib.filter (file: lib.strings.hasSuffix "default.nix" file)
      )
      ++ [
        ../lib/home-impermanence.nix
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

  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = {
    inherit
      inputs
      inputs'
      user
      ;
  };
}
