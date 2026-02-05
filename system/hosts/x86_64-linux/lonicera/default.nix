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
    ./wireguard.nix
    ./samba.nix
    ./nginx.nix
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
        "foundryvtt"
      ];
      hashedPassword = "$y$j9T$vuizYbpJtFD5LDsQwiqp20$JzCV3wHnoEJ7fXDGPZDQBImGnMoEDmTYF5mSLfbfT45";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  services = {
    zfs.enable = true;
    foundryvtt.enable = true;
    harmonia-dev = {
      cache = {
        enable = true;
        signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
      };
      daemon.enable = true;
    };
  };

  system.stateVersion = "23.11";
}
