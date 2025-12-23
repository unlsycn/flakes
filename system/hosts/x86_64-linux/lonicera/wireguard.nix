{ config, ... }:
{
  networking.wg-quick.interfaces = {
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
      ];
    };
  };

  sops.secrets.wg0 = {
    sopsFile = ./wireguard.yaml;
  };
}
