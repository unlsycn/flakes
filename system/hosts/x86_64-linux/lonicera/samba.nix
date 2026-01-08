{ ... }:
{
  services.samba = {
    enable = true;
    nmbd.enable = false;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Lonicera Via Wireguard";
        "netbios name" = "Lonicera-SMB";
        security = "user";
        "hosts allow" = "10.122.133. 127.0.0.1 localhost";
        "guest account" = "nobody";
        "map to guest" = "never";
      };

      "FoundryVTT" = {
        comment = "FoundryVTT Data (WireGuard Only)";
        path = "/var/lib/foundryvtt/Data";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = "foundryvtt";
        "force group" = "foundryvtt";
        "create mask" = "0664";
        "directory mask" = "0775";
        "valid users" = "@foundryvtt";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    445
    139
  ];
}
