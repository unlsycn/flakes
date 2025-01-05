{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.telegram;
in
with lib;
{
  imports = [ ./hyprland.nix ];

  options.programs.telegram = {
    enable = mkEnableOption "Desktop client for the Telegram messenger";
    package = mkPackageOption pkgs "Telegram Desktop" {
      default = [ "telegram-desktop" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
