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
    ./samba.nix
    ./nginx.nix
    ./buildbot.nix
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
    samba.enable = true;
    harmonia-dev = {
      cache = {
        enable = true;
        signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
      };
      daemon.enable = true;
    };
    buildbot-nix = {
      master.enable = true;
      worker.enable = true;
    };
  };

  mesh = {
    enable = true;
    id = 33;
    roles = [
      "lighthouse"
      "relay"
    ];
    publicEndpoint = "lonicera.unlsycn.com:4242";
  };

  system.stateVersion = "23.11";
}
