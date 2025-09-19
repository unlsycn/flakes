{
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    ./hardware.nix
    inputs.jovian-nixos.nixosModules.default
    ./jovian.nix
  ];

  homeManagerProfiles = [
    "cli"
    "handheld"
  ];
  isHandheld = true;

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

  users.users =
    let
      publicKeys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0YRjw/yQfCv7zYkOPqJersjDqpEInpdjjdwRTSAG4X unlsycn@unlsycn.com''
      ];
    in
    {
      root.openssh.authorizedKeys.keys = publicKeys;
      ${user} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ];
        hashedPassword = "$y$j9T$MgGlwRSeVYRBQIsdBL7Ht0$wH43pu82EUzbJAd.M1KxoTSXiRmNJ3xQyHn9za3QcRC";
        openssh.authorizedKeys.keys = publicKeys;
        shell = pkgs.zsh;
      };
    };

  services.openvpn.servers = { };

  system.stateVersion = "25.05"; # Dont touch it
}
