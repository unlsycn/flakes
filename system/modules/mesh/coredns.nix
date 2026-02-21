{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.mesh;

  nodes = inputs.self.mesh-topology;

  nebulaNodeHosts =
    nodes
    |> mapAttrsToList (nodeName: nodeData: "${nodeData.ip} ${nodeName}.${cfg.nebula.domain}")
    |> concatStringsSep "\n";

  nebulaServiceHosts =
    nodes
    |> mapAttrsToList (
      _: nodeData:
      nodeData.services
      |> filterAttrs (_: svc: svc.expose.nebula)
      |> mapAttrsToList (svcName: _: "${nodeData.ip} ${svcName}.${cfg.nebula.domain}")
    )
    |> flatten
    |> concatStringsSep "\n";

  tailnetRecords =
    nodes
    |> mapAttrsToList (
      nodeName: nodeData:
      nodeData.services
      |> filterAttrs (_: svc: svc.expose.tailscale)
      |> mapAttrsToList (svcName: _: "${svcName} IN CNAME ${nodeName}.${cfg.tailnet.nativeDomain}.")
    )
    |> flatten
    |> concatStringsSep "\n";

  tailnetZoneFile = pkgs.writeText "tailnet.zone" ''
    $ORIGIN ${cfg.tailnet.domain}.
    $TTL 300
    @ IN SOA ns1.${cfg.tailnet.domain}. admin.${cfg.tailnet.domain}. ( 1 7200 3600 1209600 3600 )
    @ IN NS ns1.${cfg.tailnet.domain}.

    ${tailnetRecords}
  '';
in
{
  config = mkIf (cfg.enable && (cfg.roles |> elem "lighthouse")) {
    services.coredns = {
      enable = true;
      config = ''
        ${cfg.nebula.domain} {
          hosts {
            ${nebulaNodeHosts}
            ${nebulaServiceHosts}
            fallthrough
          }
          log
          errors
        }

        ${cfg.tailnet.domain} {
          file ${tailnetZoneFile}
          log
          errors
        }
      '';
    };
  };
}
