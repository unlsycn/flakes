{
  inputs,
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
    package = pkgs.nix-dram;
    settings = {
      default-flake = "nixpkgs/nixos-unstable";
      experimental-features = [
        "nix-command"
        "flakes"
        "impure-derivations"
        "pipe-operators"
      ];
      substituters = [
        "https://cache.nixos.org"
      ];
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
