{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  homeManagerProfiles = [
    "intimate"
  ];
  desktop.enable = true;

  environment.persistence."/persist".enable = true;

  # mount onedrive as a separate dataset
  home-manager.users.${user}.programs.onedrive.persist = false;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    hashedPassword = "$6$zJg0P1UadaogMxN5$SifgGzUNYaK9kACNluny0j17LnFFfW4s.pjaCCPHJnQ.F55KFoEwoXJelhI7wughlksF0zNR.xwRQgpjR7X/0.";
    shell = pkgs.zsh;
  };

  services = {
    openvpn.deploy = true;
    zfs.enable = true;
  };

  mesh = {
    id = 73;
    tailnet.enable = true;
    nebula = {
      mimic.enable = true;
      portRotation = {
        enable = true;
        pool = {
          from = 38000;
          to = 38999;
        };
      };
    };
  };

  networking.hostId = "c8197f08";

  system.stateVersion = "26.05"; # Dont touch it
}
