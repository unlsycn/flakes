{ config, ... }:
{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.122.133.72/32" ];
      privateKeyFile = config.sops.secrets.wg0.path;
      peers = [
        {
          # lonicera
          publicKey = "N3F+Wr+sJZFoISjqRiDvf2LvJHY8HZotDEGGz43dDFI=";
          allowedIPs = [ "10.122.133.0/24" ];
          endpoint = "lonicera.unlsycn.com:23333";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  sops.secrets.wg0 = {
    sopsFile = ./wireguard.yaml;
  };
}
