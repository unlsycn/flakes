{
  self,
  lib,
  ...
}:
with lib;
{
  flake.mesh-topology =
    self.nixosConfigurations
    |> filterAttrs (
      _: host:
      host.config.mesh.nebula.enable
      || host.config.mesh.tailnet.enable
      || host.config.mesh.tailnet.server.enable
    )
    |> mapAttrs (
      _: host:
      {
        inherit (host.config.mesh) roles;
        system = host.pkgs.stdenv.hostPlatform.system;

        services =
          host.config.mesh.services
          |> mapAttrs (
            _: svc: {
              inherit (svc) singleDomain;
              exposure = { inherit (svc.exposure) nebula tailnet public; };
            }
          );

      }
      // optionalAttrs (host.config.mesh.tailnet.enable || host.config.mesh.tailnet.server.enable) {
        tailnet =
          optionalAttrs host.config.mesh.tailnet.enable {
            client = { };
          }
          // optionalAttrs host.config.mesh.tailnet.server.enable {
            server = { };
          };
      }
      // optionalAttrs host.config.mesh.nebula.enable {
        nebula = {
          inherit (host.config.mesh.nebula) cidr ip publicEndpoint;
        };
      }
    );
}
