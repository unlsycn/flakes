{ config, lib, ... }:
with lib;
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
    };

    extraOptions = mkIf config.sops.control.deploySecrets ''
      !include ${config.sops.templates.nix-extra-options.path}
    '';
  };

  sops = mkIf config.sops.control.deploySecrets {
    secrets.github-access-token.sopsFile = ./access-token.yaml;
    templates.nix-extra-options.content = "extra-access-tokens = github.com=${config.sops.placeholder.github-access-token}";
  };
}
