{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.programs.nnn.enable {
    home.persistence."/persist" = {
      directories = [ ".config/nnn" ];
    };
  };
}
