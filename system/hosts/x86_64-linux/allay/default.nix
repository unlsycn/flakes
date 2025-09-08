{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./sound.nix
    ./hardware-configuration.nix
  ];

  homeManagerProfiles = [
    "cli"
    "desktop"
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
    hashedPasswordFile = "/persist/passwords/user";
    shell = pkgs.zsh;
  };

  services.evremap.enable = true;
  services.evremap.settings.device_name = "AT Translated Set 2 keyboard";

  console.font = "Terminus 32";

  system.stateVersion = "25.05"; # Dont touch it
}
