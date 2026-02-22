{
  pkgs,
  user,
  sshKeys,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./networking.nix
  ];

  isServer = true;

  boot.tmp.cleanOnBoot = true;

  zramSwap.enable = true;

  users.users = {
    root.openssh.authorizedKeys.keys = sshKeys;
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      hashedPassword = "$y$j9T$vuizYbpJtFD5LDsQwiqp20$JzCV3wHnoEJ7fXDGPZDQBImGnMoEDmTYF5mSLfbfT45";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  services = {
    zfs.enable = true;
    mihomo.enable = false;
  };

  mesh = {
    enable = true;
    id = 49;
    roles = [
      "lighthouse"
    ];
    endpoint = "ukiyo.unlsycn.com";
  };

  system.stateVersion = "23.11";
}
