{
  lib,
  user,
  inputs,
  ...
}:
with lib;
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];
  environment.persistence."/persist" = {
    enable = mkDefault false;
    hideMounts = true;
    files = [ "/etc/machine-id" ];
    directories = [ "/var" ];
    users.${user} = {
      directories = [ ".nix" ];
    };
  };
}
