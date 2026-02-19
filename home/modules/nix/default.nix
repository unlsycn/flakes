{ config, ... }:
{
  nix = {
    settings = {
      default-flake = "nixpkgs";
      experimental-features = [
        "nix-command"
        "flakes"
        "impure-derivations"
        "pipe-operators"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://cache.unlsycn.com:4433"
      ];
      trusted-public-keys = [
        "cache.unlsycn.com-1:beAofQCYfkbHnku0lL7kKzAc1ZCMA4NC3GWqcp5lsio="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    extraOptions = ''
      fallback = true
      !include ${config.sops.templates.nix-extra-options.path}
    '';
  };

  sops = {
    secrets.github-access-token.sopsFile = ./access-token.yaml;
    templates.nix-extra-options.content = "extra-access-tokens = github.com=${config.sops.placeholder.github-access-token}";
  };
}
