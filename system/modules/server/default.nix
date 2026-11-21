{ config, lib, ... }:
with lib;
{
  options = {
    isServer = mkOption {
      type = types.bool;
      default = config.isBuildServer;
      description = "Server host";
    };
    isBuildServer = mkOption {
      type = types.bool;
      default = false;
      description = "Build server host";
    };
  };

  config = mkIf (config.isServer && !config.isBuildServer) {
    systemd.services.nixbot.serviceConfig = mkIf config.services.nixbot.enable {
      Nice = 19;
      CPUSchedulingPolicy = "batch";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 5;
    };
    systemd.services.nix-daemon.serviceConfig = {
      Nice = 19;
      CPUSchedulingPolicy = mkForce "batch";
      IOSchedulingPriority = mkForce 5;
    };
  };
}
