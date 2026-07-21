{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.harmonia-dev;
in
{
  imports = [ inputs.harmonia.nixosModules.harmonia ];
  options.services.harmonia-dev = {
    port = mkOption {
      type = types.port;
      default = 5000;
    };
  };
  config = lib.mkIf cfg.cache.enable {
    services.harmonia-dev.cache.settings = {
      bind = "${if config.services.nginx.enable then "127.0.0.1" else "[::]"}:${cfg.port |> toString}";
      enable_compression = true;
    };

    mesh.services.cache = {
      internalPort = cfg.port;
      internalAddress = "127.0.0.1";
      exposure = {
        nebula = true;
      };
    };

    mesh.surfaces.nebula.allowedTCPPorts = mkIf (!config.services.nginx.enable) [ cfg.port ];
  };
}
