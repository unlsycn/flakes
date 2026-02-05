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
            self.buildConfigurationPhases.genHomeConfigurationForStandalone profiles { inherit user pkgs; }
          );
      };

      checks =
        config.legacyPackages.homeConfigurations
        |> lib.mapAttrs' (name: cfg: lib.nameValuePair "home-manager-${name}" cfg.activationPackage);
    };
}
