{
  lib,
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ../../common

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = import ../../../outputs/home.nix {
        inherit inputs user lib;
        profiles = [
          "cli"
          "desktop"
        ];
      };
    }
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
      systemd-boot.enable = true;
      timeout = 1;
    };
  };

  users.users.${user} = {
    isNormalUser = true;
    hashedPasswordFile = "/persist/passwords/user";
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # workaround for https://github.com/NixOS/nix/issues/10202
  environment.persistence."/persist".files = [ "/root/.gitconfig" ];

  system.stateVersion = "25.05"; # Dont touch it
}
