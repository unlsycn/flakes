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

  services.nginx.virtualHosts."hydra.unlsycn.com" = mkIf config.services.nginx.enable {
    onlySSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/".proxyPass = "http://127.0.0.1:${config.services.hydra.port |> toString}";
  };

  networking.firewall.allowedTCPPorts = mkIf (!config.services.nginx.enable) [
    config.services.hydra.port
  ];
}
