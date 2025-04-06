{
  self,
  user,
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
        homeConfigurations = with self.buildConfigurationPhases; {
          "cli" = genHomeConfigurationForStandalone [ "cli" ] { inherit user pkgs; };
          "desktop" = genHomeConfigurationForStandalone [
            "cli"
            "desktop"
          ] { inherit user pkgs; };
          "server" = genHomeConfigurationForStandalone [ "server" ] { inherit user pkgs; };
        };
      };
    };
}
