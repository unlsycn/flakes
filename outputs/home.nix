{
  self,
  user,
  lib,
  ...
}:
{
  perSystem =
    {
      pkgs,
      config,
      inputs',
      ...
    }:
    {
      legacyPackages = {
        homeConfigurations =
          {
            "cli" = [ "cli" ];
            "desktop" = [
              "cli"
              "desktop"
            ];
            "handheld" = [
              "cli"
              "handheld"
            ];
            "intimate" = [
              "cli"
              "intimate"
            ];
            "server" = [
              "cli"
              "server"
            ];
          }
          |> lib.mapAttrs (
            _: profiles:
            self.buildConfigurationPhases.genHomeConfigurationForStandalone profiles {
              inherit user pkgs;
              extraSpecialArgs = { inherit inputs'; };
            }
          );
      };

      checks =
        config.legacyPackages.homeConfigurations
        |> lib.mapAttrs' (name: cfg: lib.nameValuePair "home-manager-${name}" cfg.activationPackage);
    };
}
