{ config, lib, ... }:
with lib;
let
  cfg = config.programs.mosh;
  portRange = {
    from = 60000;
    to = 61000;
  };
in
{
  config = mkIf cfg.enable {
    programs.mosh.openFirewall = false;

    mesh.surfaces = {
      public.allowedUDPPortRanges = [ portRange ];
      nebula.allowedUDPPortRanges = mkIf config.mesh.nebula.enable [ portRange ];
      tailnet.allowedUDPPortRanges = mkIf config.mesh.tailnet.enable [ portRange ];
    };
  };
}
