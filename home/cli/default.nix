{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = lib.filter (f: lib.strings.hasSuffix "default.nix" f) (
    lib.filesystem.listFilesRecursive ./modules
  );

  options.profile.cli = {
    enable = mkEnableOption "home-manager profile for CLI environment";
  };

  config = mkIf config.profile.cli.enable {
    programs = {
      git.enable = true;
      gpg.enable = true;
      neovim.enable = true;
      direnv.enable = true;
    };

    home.packages = with pkgs; [
      nixd
    ];
  };
}
