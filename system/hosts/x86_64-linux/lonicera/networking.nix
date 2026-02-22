{ lib, ... }:
{
  networking = {
    hostId = "7f82dd29";
    nameservers = [
      "223.5.5.5"
      "223.6.6.6"
    ];

    defaultGateway = {
      address = "114.66.58.1";
      interface = "ens18";
    };

    defaultGateway6 = null;

    useDHCP = false;
    usePredictableInterfaceNames = lib.mkForce true;

    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "114.66.58.149";
            prefixLength = 24;
          }
        ];
        ipv4.routes = [
          {
            address = "114.66.58.1";
            prefixLength = 32;
          }
        ];
      };
      ens19 = {
        ipv4.addresses = [
          {
            address = "172.16.40.210";
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
    ATTR{address}=="bc:24:11:72:7a:ac", NAME="ens18"
    ATTR{address}=="bc:24:11:45:27:55", NAME="ens19"
  '';

  services.openvpn.servers = { };
}
