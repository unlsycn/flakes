{
  self,
  lib,
  ...
}:
with builtins;
{
  flake.nixosConfigurations =
    with self.buildConfigurationPhases;
    ../system/hosts
    |> readDir
    |> attrNames
    |> map (
      system:
      ../system/hosts/${system} |> readDir |> attrNames |> map (host: genNixosConfiguration system host)
    )
    |> lib.flatten
    |> listToAttrs;
}
