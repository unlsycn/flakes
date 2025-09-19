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
            "server" = [ "server" ];
          }
          |> lib.mapAttrs (
            _: profiles:
            self.buildConfigurationPhases.genHomeConfigurationForStandalone profiles { inherit user pkgs; }
          );
      };
    };
}
