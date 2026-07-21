{
  config,
  options,
  lib,
  ...
}:
with lib;
let
  cfg = config.mesh;
in
{
  imports = [
    ./options.nix
  ];

  config = mkMerge [
    {
      mesh.surfaces = mkMerge [
        {
          public.interface = mkDefault (config.networking.defaultGateway.interface or null);
        }
        (mkIf cfg.nebula.enable {
          nebula.interface = mkDefault config.services.nebula.networks.senesperejo.tun.device;
        })
        (mkIf cfg.tailnet.enable {
          tailnet.interface = mkDefault "tailscale0";
        })
      ];

      assertions =
        (
          cfg.services
          |> mapAttrsToList (
            name: svc: {
              assertion = svc.exposure.nebula -> cfg.nebula.enable;
              message = "mesh.services.${name}.exposure.nebula requires mesh.id on this host";
            }
          )
        )
        ++ (
          cfg.services
          |> mapAttrsToList (
            name: svc: {
              assertion = svc.exposure.tailnet -> cfg.tailnet.enable;
              message = "mesh.services.${name}.exposure.tailnet requires mesh.tailnet.enable on this host";
            }
          )
        )
        ++ (
          cfg.services
          |> mapAttrsToList (
            name: svc: {
              assertion = !svc.singleDomain || (svc.exposure.nebula && svc.exposure.tailnet);
              message = "mesh.services.${name}.singleDomain requires both Nebula and Tailnet exposure";
            }
          )
        )
        ++ (
          cfg.services
          |> mapAttrsToList (
            name: svc: {
              assertion = !svc.exposure.public || svc.publicDomain != null;
              message = "mesh.services.${name}.exposure.public requires publicDomain";
            }
          )
        )
        ++ [
          {
            assertion = cfg.tailnet.enable -> config.networking.firewall.enable;
            message = "mesh.tailnet.enable = true requires networking.firewall.enable = true";
          }
        ];
    }

    (mkIf config.networking.firewall.enable {
      networking.firewall =
        let
          interfaceSurfaces = cfg.surfaces |> attrValues |> filter (s: s.interface != null);
          sortPorts = ports: ports |> unique |> sort lessThan;
          sortRanges =
            ranges: ranges |> unique |> sort (a: b: a.from < b.from || (a.from == b.from && a.to < b.to));
          mergeSurfaceRules =
            surfaces:
            {
              allowedTCPPorts = sortPorts;
              allowedUDPPorts = sortPorts;
              allowedTCPPortRanges = sortRanges;
              allowedUDPPortRanges = sortRanges;
            }
            |> mapAttrs (name: sortRule: surfaces |> concatMap (s: s.${name}) |> sortRule);
        in
        {
          interfaces = interfaceSurfaces |> groupBy (s: s.interface) |> mapAttrs (_: mergeSurfaceRules);

          trustedInterfaces =
            interfaceSurfaces
            |> filter (s: s.trusted)
            |> map (s: s.interface)
            |> unique;

          inherit
            (mergeSurfaceRules (
              optional (cfg.surfaces ? public && cfg.surfaces.public.interface == null) cfg.surfaces.public
            ))
            allowedTCPPorts
            allowedUDPPorts
            allowedTCPPortRanges
            allowedUDPPortRanges
            ;
        };

      assertions =
        let
          missingInterfaceSurfaces =
            cfg.surfaces
            |> mapAttrsToList (name: surface: { inherit name surface; })
            |> filter (
              entry:
              (
                entry.surface.trusted
                || entry.surface.allowedTCPPorts != [ ]
                || entry.surface.allowedUDPPorts != [ ]
                || entry.surface.allowedTCPPortRanges != [ ]
                || entry.surface.allowedUDPPortRanges != [ ]
              )
              && entry.surface.interface == null
              && (entry.name != "public" || entry.surface.trusted)
            )
            |> map (entry: "mesh.surfaces.${entry.name}");

          offendingDefs =
            [
              "allowedTCPPorts"
              "allowedUDPPorts"
              "allowedTCPPortRanges"
              "allowedUDPPortRanges"
            ]
            |> concatMap (
              name:
              options.networking.firewall.${name}.definitionsWithLocations
              |> filter (
                d:
                let
                  source = d.file |> toString;
                in
                d.value != [ ] && source != toString ./.
              )
              |> map (d: "networking.firewall.${name} <- ${toString d.file}")
            );
        in
        [
          {
            assertion = missingInterfaceSurfaces == [ ];
            message = ''
              Mesh surfaces with trusted access or non-public rules must declare an interface.
              Missing interfaces:
              ${concatStringsSep "\n" missingInterfaceSurfaces}
            '';
          }
          {
            assertion = offendingDefs == [ ];
            message = ''
              A module wrote a global networking.firewall.allowed* list, which the mesh surface model forbids.
              Declare the intended surface via mesh.surfaces.<public|nebula|tailnet>.* instead.
              Offending definitions:
              ${concatStringsSep "\n" offendingDefs}
            '';
          }
        ];
    })
  ];
}
