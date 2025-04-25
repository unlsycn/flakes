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
    programs.msedge.package = pkgs.microsoft-edge.override {
      commandLineArgs = ''
        --enable-features=TouchpadOverscrollHistoryNavigation \
        --enable-blink-features=MiddleClickAutoscroll'';
    };
    home.packages = [ cfg.package ];
    persist."/persist".users.${user} = {
      directories = [ ".config/microsoft-edge" ];
    };
  };
}
