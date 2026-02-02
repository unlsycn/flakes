{
  pkgs,
  user,
  sshKeys,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  isServer = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.cleanOnBoot = true;
  };

  zramSwap.enable = true;

  users.users = {
    root.openssh.authorizedKeys.keys = sshKeys;
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "foundryvtt"
      ];
      hashedPassword = "$y$j9T$vuizYbpJtFD5LDsQwiqp20$JzCV3wHnoEJ7fXDGPZDQBImGnMoEDmTYF5mSLfbfT45";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  services = {
    mihomo.tunMode = false;
    openvpn.servers = { };
  };
  networking.proxy.default = "http://127.0.0.1:1970";

  system.stateVersion = "23.11";
}
