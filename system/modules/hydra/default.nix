{ config, lib, ... }:
with lib;
{
  services.hydra = {
    port = 30073;
    listenHost = if config.services.nginx.enable then "localhost" else "*";
    smtpHost = "smtp.qiye.aliyun.com";
    notificationSender = "hydra@unlsycn.com";
    minimumDiskFree = 4;
    useSubstitutes = true;
  };
  networking.firewall.allowedTCPPorts = mkIf (!config.services.nginx.enable) [
    config.services.hydra.port
  ];
}
