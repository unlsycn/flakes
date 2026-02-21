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
          services
          ;
        inherit (host.config.mesh.nebula) ip cidr publicEndpoint;
        system = host.pkgs.stdenv.hostPlatform.system;
      }
    );
}
