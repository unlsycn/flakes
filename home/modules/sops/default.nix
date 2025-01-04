{ config, user, ... }:
{
  sops.age.keyFile = "${config.xdg.configHome}/age/key";

  persist."/persist".users.${user}.files = [ ".config/age/key" ];
}
