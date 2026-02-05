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
      type = types.int;
      default = 5000;
    };
  };
  config = lib.mkIf cfg.cache.enable {
    services.harmonia-dev.cache.settings = {
      bind = "${if config.services.nginx.enable then "localhost" else "[::]"}:${cfg.port |> toString}";
      enable_compression = true;
    };
    networking.firewall.allowedTCPPorts = mkIf (!config.services.nginx.enable) [
      cfg.port
    ];
  };
}
