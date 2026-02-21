{ config, lib, ... }:
with lib;
with builtins;
let
  cfg = config.mesh;
in
{
  config = mkIf (cfg.enable && cfg.services != { }) {
    services.nginx = {
      enable = mkDefault true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      clientMaxBodySize = "1024m";

      virtualHosts =
        cfg.services
        |> concatMapAttrs (
          name: svc:
          let
            mkVHost =
              type:
              let
                vhostName =
                  if type == "nebula" then
                    "${name}.${cfg.nebula.domain}"
                  else if type == "tailscale" then
                    "${name}.${cfg.tailnet.domain}"
                  else
                    svc.publicDomain;

                sslConfig =
                  if type == "nebula" then
                    {
                      sslCertificate = ./esper-ejo.crt;
                      sslCertificateKey = config.sops.secrets.nebula-domain-key.path;
                      forceSSL = true;
                    }
                  else
                    {
                      enableACME = true;
                      acmeRoot = null;
                      forceSSL = true;
                    };

                listenConfig =
                  if type == "nebula" then
                    [
                      {
                        addr = cfg.nebula.ip;
                        port = 443;
                        ssl = true;
                      }
                      {
                        addr = cfg.nebula.ip;
                        port = 80;
                      }
                    ]
                  else
                    [ ];
              in
              {
                ${vhostName} = {
                  inherit (svc) locations extraConfig;
                }
                // sslConfig
                // optionalAttrs (listenConfig != [ ]) { listen = listenConfig; };
              };
          in
          (optionalAttrs svc.expose.nebula (mkVHost "nebula"))
          // (optionalAttrs svc.expose.tailscale (mkVHost "tailscale"))
          // (optionalAttrs (svc.expose.public && svc.publicDomain != null) (mkVHost "public"))
        );
    };

    users.users.nginx.extraGroups = [ "acme" ];

    sops.secrets.nebula-domain-key = {
      sopsFile = ./esper-ejo.key;
      format = "binary";
      owner = "nginx";
    };
  };
}
