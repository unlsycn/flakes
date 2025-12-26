{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./wireguard.nix
    ./samba.nix
  ];

  homeManagerProfiles = [
    "server"
  ];

  boot.tmp.cleanOnBoot = true;

  zramSwap.enable = true;

  users = {
    users =
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
            "foundryvtt"
          ];
          hashedPassword = "$y$j9T$vuizYbpJtFD5LDsQwiqp20$JzCV3wHnoEJ7fXDGPZDQBImGnMoEDmTYF5mSLfbfT45";
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = publicKeys;
        };
      };
  };

  services = {
    zfs.enable = true;
    foundryvtt.enable = true;
  };

  system.stateVersion = "23.11";
}
