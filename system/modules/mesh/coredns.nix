{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.mesh;
in
{
  config = mkIf (cfg.enable && (cfg.roles |> elem "lighthouse")) {
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    services.coredns = {
      enable = true;
      config = ''
        ${cfg.domain} {
          hosts {
            ${
              inputs.self.mesh-topology
              |> mapAttrsToList (name: v: "${v.ip} ${name}.${cfg.domain}")
              |> concatStringsSep "\n"
            }
            fallthrough
          }
          log
          errors
        }
      '';
    };
  };
}
