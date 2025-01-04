{ config, ... }:
{
  nix = {
    extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';
  };

  sops.secrets.nix-access-tokens.sopsFile = ./access-token.yaml;
}
