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

  perSystem =
    {
      lib,
      system,
      ...
    }:
    {
      checks =
        self.nixosConfigurations
        |> lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
        |> lib.mapAttrs' (name: cfg: lib.nameValuePair "nixos-${name}" cfg.config.system.build.toplevel);
    };
}
