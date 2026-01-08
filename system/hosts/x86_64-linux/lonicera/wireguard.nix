{ config, ... }:
{
  networking = {
    wg-quick.interfaces = {
      wg0 = {
        address = [ "10.122.133.1/24" ];
        listenPort = 23333;
        privateKeyFile = config.sops.secrets.wg0.path;
        peers = [
          {
            # allay
            publicKey = "ZMGy0DibJp7pvC8E4OGXhmUuEXpiNwinx4sPxZ1TUCU=";
            allowedIPs = [ "10.122.133.72/32" ];
          }
          {
            publicKey = "TNXQNQSFMs0XKWpXpjVBIoSCYRcbPie7KnmMZ47vC1U=";
            allowedIPs = [ "10.122.133.73/32" ];
          }
          {
            publicKey = "mkGpgHDEQVCAKTaYCZCsa8PoqmQ00UNX801PrG+nQnc=";
            allowedIPs = [ "10.122.133.41/32" ];
          }
        ];
      };
    };
    firewall = {
      allowedUDPPorts = [ config.networking.wg-quick.interfaces.wg0.listenPort ];
      trustedInterfaces = [ "wg0" ];
      extraForwardRules = ''
        iifname "wg0" oifname "wg0" accept
      '';
    };
  };

  sops.secrets.wg0 = {
    sopsFile = ./wireguard.yaml;
  };
}
