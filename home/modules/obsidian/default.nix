{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.obsidian;
in
with lib;
let
  better-sqlite3 = pkgs.callPackage ./better-sqlite3.nix { };
in
{
  options.programs.obsidian = {
    enable = mkEnableOption "Powerful knowledge base that works on top of a local folder of plain text Markdown files";
    package = mkPackageOption pkgs "Obsidian" {
      default = [ "obsidian" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.dataFile."Zotero/better_sqlite3.node".source = better-sqlite3;
  };
}
