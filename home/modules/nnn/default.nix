{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  config = mkIf config.programs.nnn.enable {
    persist."/persist".users.${user} = {
      directories = [ ".config/nnn" ];
    };
  };
}
