{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.gtk;
in
{
  config = mkIf cfg.enable {
    gtk.cursorTheme = {
      size = 32;
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
    };
  };
}
