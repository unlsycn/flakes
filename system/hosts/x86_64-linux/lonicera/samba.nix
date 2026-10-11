{ config, ... }:
{
  services.samba = {
    nmbd.enable = false;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Lonicera Via Tailnet";
        "netbios name" = "Lonicera-SMB";
        security = "user";
        "hosts allow" = "${config.mesh.tailnet.prefixes.v4} 127.0.0.1 localhost";
        "guest account" = "nobody";
        "map to guest" = "never";
      };

      "FoundryVTT" = {
        comment = "FoundryVTT Data (Tailnet Only)";
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

  mesh.surfaces.tailnet.allowedTCPPorts = [
    445
    139
  ];
}
