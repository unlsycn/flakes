{
  lib,
  user,
  ...
}:
with lib;
{
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
