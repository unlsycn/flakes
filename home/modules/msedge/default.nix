{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.programs.msedge;
in
with lib;
{
  imports = [ ./hyprland.nix ];

  options.programs.msedge = {
    enable = mkEnableOption "Web browser from Microsoft";
    package = mkPackageOption pkgs "Microsoft Edge" {
      default = [ "microsoft-edge" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    persist."/persist".users.${user} = {
      directories = [ ".config/microsoft-edge" ];
    };
  };
}
