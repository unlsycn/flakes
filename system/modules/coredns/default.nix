{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mesh;

  nodes = inputs.self.mesh-topology |> filterAttrs (_: n: n ? nebula);

  authoritativeNameservers =
    nodes
    |> filterAttrs (_: n: n.roles |> elem "lighthouse")
    |> attrNames
    |> map (nodeName: "${nodeName}.${cfg.nebula.domain}.");

  nebulaNodeRecords =
    nodes |> mapAttrsToList (nodeName: n: "${nodeName}.${cfg.nebula.domain}. IN A ${n.nebula.ip}");

  nebulaServiceRecords =
    nodes
    |> mapAttrsToList (
      _: n:
      n.services
      |> filterAttrs (_: svc: svc.exposure.nebula)
      |> mapAttrsToList (svcName: _: "${svcName}.${cfg.nebula.domain}. IN A ${n.nebula.ip}")
    )
    |> flatten;

  tsScopedRecords =
    nodes
    |> mapAttrsToList (
      _: n:
      n.services
      |> filterAttrs (_: svc: svc.singleDomain && svc.exposure.nebula && svc.exposure.tailnet)
      # Publish plane-local A records instead of CNAMEs into MagicDNS:
      # https://github.com/tailscale/tailscale/issues/7650
      # https://github.com/tailscale/tailscale/issues/5033
      |> mapAttrsToList (svcName: _: "${svcName}.${cfg.tailnet.domain}. IN A ${n.nebula.ip}")
    )
    |> flatten;

  mkZoneFile =
    domain: records:
    pkgs.writeText "${replaceStrings [ "." ] [ "-" ] domain}.zone" ''
      $ORIGIN ${domain}.
      $TTL 3600
      @ IN SOA ${authoritativeNameservers |> head} admin.unlsycn.com. (
        1
        3600
        600
        86400
        60
      )
      ${authoritativeNameservers |> map (nameserver: "@ IN NS ${nameserver}") |> concatStringsSep "\n"}
      ${records |> concatStringsSep "\n"}
    '';
in
{
  config = mkIf (cfg.nebula.enable && (cfg.roles |> elem "lighthouse")) {
    services.coredns = {
      enable = true;
      config = ''
        ${cfg.nebula.domain} {
          bind ${cfg.nebula.ip}
          file ${mkZoneFile cfg.nebula.domain (nebulaNodeRecords ++ nebulaServiceRecords)}
          log
          errors
        }

        ${cfg.tailnet.domain} {
          bind ${cfg.nebula.ip}
          file ${mkZoneFile cfg.tailnet.domain tsScopedRecords}
          log
          errors
        }
      '';
    };

    mesh.surfaces.nebula = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
