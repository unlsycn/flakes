{
  lib,
  pkgs,
  hostName,
  ...
}:
with lib;
{
  imports = [
    ./network.nix
    ./security.nix
    ./services.nix
  ];

  networking.hostName = hostName;

  time.timeZone = mkDefault "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

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
  programs.zsh.enable = true;
}
