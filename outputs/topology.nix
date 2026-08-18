{
  self,
  lib,
  ...
}:
with lib;
{
  flake.mesh-topology =
    let
      meshHosts =
        self.nixosConfigurations
        |> filterAttrs (
          _: host:
          host.config.mesh.nebula.enable
          || host.config.mesh.tailnet.enable
          || host.config.mesh.tailnet.server.enable
        );

      publishedNames =
        meshHosts
        |> attrValues
        |> concatMap (host: host.config.mesh.services |> attrValues |> map (svc: toLower svc.serviceName));

      duplicatedNames =
        publishedNames |> filter (name: count (other: other == name) publishedNames > 1) |> unique;
    in
    assert assertMsg (duplicatedNames == [ ])
      "Mesh service names must be globally unique across mesh hosts (case-insensitive), duplicated: ${toString duplicatedNames}";
    meshHosts
    |> mapAttrs (
      _: host:
      {
        inherit (host.config.mesh) roles;
        system = host.pkgs.stdenv.hostPlatform.system;

        services =
          host.config.mesh.services
          |> mapAttrs' (
            _: svc:
            nameValuePair svc.serviceName {
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
