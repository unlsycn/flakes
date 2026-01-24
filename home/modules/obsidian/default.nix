{
  config,
  user,
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
  config = mkIf cfg.enable {
    xdg.dataFile."Zotero/better_sqlite3.node".source = better-sqlite3;

    persist."/persist".users.${user} = {
      directories = [ ".config/obsidian" ];
    };
  };
}
