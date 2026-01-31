{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zotero;
in
with lib;
{
  options.programs.zotero = {
    enable = mkEnableOption "A free, easy-to-use tool to help you collect, organize, annotate, cite, and share research";
    package = mkPackageOption pkgs "Zotero" {
      default = [ "zotero" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.persistence."/persist".directories = [
      ".zotero"
    ];
  };
}
