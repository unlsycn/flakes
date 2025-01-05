{
  user,
  inputs,
  ...
}:
{
  perSystem =
    {
      inputs',
      pkgs,
      ...
    }:
    let
      genHomeConfiguration = profiles: {
        ${user} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (pkgs.callPackage ../home {
              inherit
                user
                inputs
                inputs'
                profiles
                ;
            }).users.${user}
            {
              # for standalone home-manager
              nix.package = pkgs.nix;
              home.username = "${user}";
              home.homeDirectory = "/home/${user}";
              programs.home-manager.enable = true;
            }
          ];
        };
      };

    in
    {
      legacyPackages = {
        homeConfigurations = genHomeConfiguration [ "cli" ];
        homeConfigurationsWithDesktop = genHomeConfiguration [
          "cli"
          "desktop"
        ];
      };
    };
}
