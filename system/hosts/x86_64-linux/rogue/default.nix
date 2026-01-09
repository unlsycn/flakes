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
    "cli"
    "handheld"
  ];

  handheld = {
    enable = true;
    hhd.enable = true;
  };

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot.enable = true;
      timeout = 1;
    };
  };

  console.font = "latarcyrheb-sun32";

  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      hashedPassword = "$y$j9T$MgGlwRSeVYRBQIsdBL7Ht0$wH43pu82EUzbJAd.M1KxoTSXiRmNJ3xQyHn9za3QcRC";
      shell = pkgs.zsh;
    };
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    openvpn.servers = { };
  };

  jovian = {
    hardware.has.amd.gpu = true;
    devices.ally-z1e.enable = true;
  };

  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Dont touch it
}
