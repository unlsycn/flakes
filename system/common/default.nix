{
  pkgs,
  hostName,
  user,
  ...
}:
{
  imports = [
    ./network.nix
    ./security.nix
    ./services.nix
    ./impermanence.nix
    ./workarounds.nix
  ];

  networking.hostName = hostName;

  boot.loader.timeout = 1;
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
    font = "Terminus 32";
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "impure-derivations"
        "pipe-operators"
      ];
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services.logind.powerKey = "hibernate";
  powerManagement.powertop.enable = true;

  systemd.services.nix-daemon = {
    environment = {
      TMPDIR = "/var/cache/nix";
    };
    serviceConfig = {
      CacheDirectory = "nix";
    };
  };
  environment.variables.NIX_REMOTE = "daemon";

  programs.nix-ld.enable = true;

  environment.persistence."/persist".hideMounts = true;
  environment.persistence."/persist" = {
    files = [ "/etc/machine-id" ];
  };
  environment.persistence."/persist".users.${user} = {
    directories = [ ".nix" ];
  };

}
