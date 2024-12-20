{
  config,
  lib,
  pkgs,
  user,
  ...
}:
with lib;
{
  options.programs.msedge.enable = mkEnableOption "Web browser from Microsoft";

  config = mkIf config.programs.msedge.enable {
    home.packages = [ pkgs.microsoft-edge ];

    persist."/persist".users.${user} = {
      directories = [ ".config/microsoft-edge" ];
    };
  };
}
