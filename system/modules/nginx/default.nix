{ config, lib, ... }:
with lib;
let
  cfg = config.mesh;
  services =
    cfg.services
    |> filterAttrs (_: svc: svc.exposure.nebula || svc.exposure.tailnet || svc.exposure.public);
  hasNebulaVHost = services |> attrValues |> any (s: s.exposure.nebula);
  hasTailnetService = services |> attrValues |> any (s: s.exposure.tailnet);
  hasPublicService = services |> attrValues |> any (s: s.exposure.public);
in
{
  config = mkIf (services != { }) {
    assertions =
      services
      |> mapAttrsToList (
        name: svc: {
          assertion = (svc.internalAddress != null && svc.internalPort != null) || svc.locations != { };
          message = "mesh.services.${name} must set either internalAddress/internalPort or custom locations";
        }
      );

    services.nginx =
      let
        mkAccessPolicy =
          denyFlagName: allowedSources:
          let
            denyFlag = "\$${denyFlagName}";
          in
          {
            serverGuard = "if (${denyFlag}) { return 403; }\n";
            httpConfig =
              (
                [
                  "geo $realip_remote_addr ${denyFlag} {"
                  "default 1;"
                ]
                ++ (allowedSources |> map (source: "${source} 0;"))
                ++ [ "}" ]
              )
              |> concatStringsSep "\n";
          };
        accessPolicies = {
          tailnet = mkAccessPolicy "mesh_tailnet_denied" [
            cfg.tailnet.prefixes.v4
            cfg.tailnet.prefixes.v6
          ];
          tailnetOrNebula = mkAccessPolicy "mesh_tailnet_or_nebula_denied" [
            cfg.tailnet.prefixes.v4
            cfg.tailnet.prefixes.v6
            cfg.nebula.cidr
          ];
        };
      in
      {
        enable = true;
        recommendedProxySettings = mkDefault true;
        recommendedTlsSettings = mkDefault true;

        virtualHosts =
          let
            internalTLS = {
              sslCertificate = ./esper-ejo.crt;
              sslCertificateKey = config.sops.secrets.nebula-domain-key.path;
              forceSSL = true;
            };
            acmeTLS = {
              enableACME = true;
              acmeRoot = null;
              forceSSL = true;
            };
            nebulaListen = [
              {
                addr = cfg.nebula.ip;
                port = 443;
                ssl = true;
              }
              {
                addr = cfg.nebula.ip;
                port = 80;
              }
            ];
            mkVHost =
              name: tls: settings:
              nameValuePair name (tls // settings);
            mkServiceVHosts =
              name: svc:
              let
                e = svc.exposure;
                tsName = "${name}.${cfg.tailnet.domain}";
                ejoName = "${name}.${cfg.nebula.domain}";
              in
              (
                if svc.singleDomain then
                  [
                    (mkVHost tsName acmeTLS {
                      listen = nebulaListen ++ [
                        {
                          addr = "0.0.0.0";
                          port = 443;
                          ssl = true;
                        }
                        {
                          addr = "[::]";
                          port = 443;
                          ssl = true;
                        }
                        {
                          addr = "0.0.0.0";
                          port = 80;
                        }
                        {
                          addr = "[::]";
                          port = 80;
                        }
                      ];
                      inherit (svc) locations;
                      extraConfig = accessPolicies.tailnetOrNebula.serverGuard + svc.extraConfig;
                    })
                    (mkVHost ejoName internalTLS {
                      listen = nebulaListen;
                      globalRedirect = tsName;
                      redirectCode = 308;
                    })
                  ]
                else
                  (optional e.nebula (
                    mkVHost ejoName internalTLS {
                      listen = nebulaListen;
                      inherit (svc) locations extraConfig;
                    }
                  ))
                  ++ (optional e.tailnet (
                    mkVHost tsName acmeTLS {
                      inherit (svc) locations;
                      extraConfig = accessPolicies.tailnet.serverGuard + svc.extraConfig;
                    }
                  ))
              )
              ++ (optional e.public (
                mkVHost svc.publicDomain acmeTLS {
                  inherit (svc) locations extraConfig;
                }
              ));
            vhostDefinitions = services |> mapAttrsToList mkServiceVHosts |> concatLists;
            vhostNames = vhostDefinitions |> map (vhost: toLower vhost.name);
          in
          assert assertMsg (
            (vhostNames |> length) == (vhostNames |> unique |> length)
          ) "Mesh service virtual host names must be unique on each host";
          vhostDefinitions |> listToAttrs;

        appendHttpConfig = mkIf hasTailnetService (
          accessPolicies
          |> attrValues
          |> map (policy: policy.httpConfig)
          |> concatStringsSep "\n"
        );
      };

    mesh.surfaces = {
      nebula.allowedTCPPorts = mkIf hasNebulaVHost [
        80
        443
      ];
      tailnet.allowedTCPPorts = mkIf hasTailnetService [
        80
        443
      ];
      public.allowedTCPPorts = mkIf hasPublicService [
        80
        443
      ];
    };

    sops.secrets.nebula-domain-key = mkIf hasNebulaVHost {
      sopsFile = ./esper-ejo.key;
      format = "binary";
      owner = "nginx";
    };
  };
}
