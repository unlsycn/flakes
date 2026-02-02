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
    };
}
