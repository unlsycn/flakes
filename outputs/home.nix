{
  lib,
  inputs,
  user,
  profiles,
  system,
  ...
}:
let
  profileList = builtins.attrNames (builtins.readDir ../home/profiles);
in
{
  users.${user} = {
    imports =
      map (profile: ../home/profiles/${profile}) profileList
      ++ lib.filter (f: lib.strings.hasSuffix "default.nix" f) (
        lib.filesystem.listFilesRecursive ../home/modules
      )
      ++ [
        ../lib/home-impermanence.nix
        inputs.vscode-server.homeModules.default
      ];

    profile = builtins.listToAttrs (
      builtins.map (profile: {
        name = "${profile}";
        value = {
          enable = builtins.elem "${profile}" profiles;
        };
      }) profileList
    );

    # for standalone home-manager
    home.username = "${user}";
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "24.05"; # Dont touch it
    programs.home-manager.enable = true;
  };

  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = { inherit inputs user system; };
}
