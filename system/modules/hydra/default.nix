{ config, lib, ... }:
with lib;
{
  config = mkIf config.services.hydra.enable {
    services.hydra = {
      port = 30073;
      listenHost = if config.services.nginx.enable then "localhost" else "*";
      smtpHost = "smtp.qiye.aliyun.com";
      notificationSender = "hydra@unlsycn.com";
      minimumDiskFree = 4;
      useSubstitutes = true;
    };

    mesh.services.hydra = mkIf config.services.nginx.enable {
      internalPort = config.services.hydra.port;
      internalAddress = "127.0.0.1";
      expose = {
        nebula = true;
      };
      publicDomain = "hydra.unlsycn.com";
    };

    networking.firewall.allowedTCPPorts = mkIf (!config.services.nginx.enable) [
      config.services.hydra.port
    ];
  };
}
