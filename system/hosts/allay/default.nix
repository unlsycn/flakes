{
  lib,
  pkgs,
  user,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ../../common

    ../../modules/desktop
    ../../modules/hyprland

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = import ../../../outputs/home.nix {
        inherit
          inputs
          user
          lib
          system
          ;
        profiles = [
          "cli"
          "desktop"
        ];
      };
    }
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_testing;
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

  programs.hyprland.enable = true;

  # workaround for https://github.com/NixOS/nix/issues/10202
  environment.persistence."/persist".files = [ "/root/.gitconfig" ];

  system.stateVersion = "25.05"; # Dont touch it
}
