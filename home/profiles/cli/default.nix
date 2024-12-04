{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.profile.cli = {
    enable = mkEnableOption "home-manager profile for CLI environment";
  };

  config = mkIf config.profile.cli.enable {
    xdg.enable = true;

    programs = {
      git.enable = true;
      gpg.enable = true;
      neovim.enable = true;
      direnv.enable = true;
    };

    services = {
      gpg-agent.enable = true;
    };

    home.packages = with pkgs; [
      nixd
    ];
  };
}
