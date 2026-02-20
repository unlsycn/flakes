{
  self,
  lib,
  ...
}:
with lib;
{
  flake.mesh-topology =
    self.nixosConfigurations
    |> filterAttrs (_: host: host.config.mesh.enable)
    |> mapAttrs (
      _: host: {
        inherit (host.config.mesh)
          roles
          publicEndpoint
          ip
          ;
        inherit (host.config.mesh.nebula) cidr;
        system = host.pkgs.stdenv.hostPlatform.system;
      }
    );
}
