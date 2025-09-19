{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./sound.nix
    ./hardware.nix
  ];

  homeManagerProfiles = [
    "cli"
    "desktop"
    "intimate"
  ];
  hasDesktopEnvironment = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 16;
      };
      timeout = 1;
    };
  };

  environment.persistence."/persist".enable = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    hashedPassword = "$6$zJg0P1UadaogMxN5$SifgGzUNYaK9kACNluny0j17LnFFfW4s.pjaCCPHJnQ.F55KFoEwoXJelhI7wughlksF0zNR.xwRQgpjR7X/0.";
    shell = pkgs.zsh;
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    evremap = {
      enable = true;
      settings.device_name = "AT Translated Set 2 keyboard";
    };
  };

  system.stateVersion = "25.05"; # Dont touch it
}
