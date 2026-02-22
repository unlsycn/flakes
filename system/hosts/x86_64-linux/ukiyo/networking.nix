{ lib, ... }:
{
  networking = {
    hostId = "55683811";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    defaultGateway = {
      address = "154.36.185.254";
      interface = "ens18";
    };

    useDHCP = false;
    usePredictableInterfaceNames = lib.mkForce true;

    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "154.36.185.123";
            prefixLength = 24;
          }
        ];
        ipv4.routes = [
          {
            address = "154.36.185.254";
            prefixLength = 32;
          }
        ];
      };
      ens19 = {
        ipv4.addresses = [
          {
            address = "172.16.34.98";
            prefixLength = 16;
          }
        ];
      };
    };

    firewall = {
      allowedTCPPortRanges = [
        {
          from = 24000;
          to = 25000;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 24000;
          to = 25000;
        }
      ];
    };
  };

  services.udev.extraRules = ''
    ATTR{address}=="bc:24:11:0e:61:ef", NAME="ens18"
    ATTR{address}=="bc:24:11:65:03:20", NAME="ens19"
  '';

  services.openvpn.servers = { };
}
