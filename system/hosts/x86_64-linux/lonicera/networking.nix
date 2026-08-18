{ ... }:
{
  networking = {
    hostId = "7f82dd29";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    interfaces.eth0.useDHCP = true;
    usePredictableInterfaceNames = false;
  };

  mesh = {
    id = 33;
    roles = [
      "lighthouse"
      "relay"
    ];
    endpoint = "lonicera.unlsycn.com";
    tailnet = {
      enable = true;
      server.enable = true;
    };
    surfaces.public.interface = "eth0";
  };
}
