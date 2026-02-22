{
  self,
  inputs,
  lib,
  ...
}:
with builtins;
{
  flake = {
    nixosConfigurations =
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

    deploy.nodes =
      self.nixosConfigurations
      |> lib.mapAttrs (
        name: cfg: {
          hostname = name;
          sshUser = if cfg.config.isServer then "root" else "unlsycn";
          interactiveSudo = if cfg.config.isServer then false else true;
          sudo = if cfg.config.security.doas.enable then "doas -u" else "sudo -u";
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.${cfg.pkgs.stdenv.hostPlatform.system}.activate.nixos cfg;
          };
        }
      );
  };

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
