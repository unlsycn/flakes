{ config, ... }:
{
  nix = {
    extraOptions = ''
      !include ${config.sops.templates.nix-extra-options.path}
    '';
  };

  sops = {
    secrets.github-access-token.sopsFile = ./access-token.yaml;
    templates.nix-extra-options.content = "extra-access-tokens = github.com=${config.sops.placeholder.github-access-token}";
  };
}
