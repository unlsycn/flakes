{
  pkgs,
  lib,
  user,
  ...
}:
with lib;
{
  imports = [
    ./hardware.nix
  ];

  homeManagerProfiles = [
    "server"
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.cleanOnBoot = true;
  };

  zramSwap.enable = true;

  users = {
    mutableUsers = true;
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
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = publicKeys;
        };
      };
  };

  services = {
    mihomo.tunMode = false;
    openvpn.servers = mkForce { };
  };
  networking.proxy.default = "http://127.0.0.1:1970";

  system.stateVersion = "23.11";
}
