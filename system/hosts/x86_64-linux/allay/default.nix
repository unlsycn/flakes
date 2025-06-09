{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./sound.nix
    ./hardware-configuration.nix
    ../../../common

    ../../../modules/desktop
    ../../../modules/evremap
  ];

  homeManagerProfiles = [
    "cli"
    "desktop"
  ];

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

  users.users.${user} = {
    isNormalUser = true;
    hashedPasswordFile = "/persist/passwords/user";
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  programs.hyprland.enable = true;

  services.evremap.enable = true;
  services.evremap.settings.device_name = "AT Translated Set 2 keyboard";

  system.stateVersion = "25.05"; # Dont touch it
}
