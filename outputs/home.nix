{
  inputs,
  user,
  profiles,
  ...
}:
let
  profileList = builtins.attrNames (builtins.readDir ../home);
in
{
  users.${user} = {
    imports = map (profile: ../home/${profile}) profileList ++ [
      ../lib/home-impermanence.nix
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
  extraSpecialArgs = { inherit inputs user; };
}
