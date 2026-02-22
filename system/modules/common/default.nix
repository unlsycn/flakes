{
  config,
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
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = mkIf config.mesh.nebula.enable [
        "https://cache.esper.ejo"
      ];
      trusted-public-keys = mkIf config.mesh.nebula.enable [
        "cache.unlsycn.com-1:beAofQCYfkbHnku0lL7kKzAc1ZCMA4NC3GWqcp5lsio="
      ];
    };
    extraOptions = ''
      builders-use-substitutes = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  users.mutableUsers = mkDefault false;

  services.logind.settings.Login.HandlePowerKey = mkDefault "hibernate";
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
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
  };
}
