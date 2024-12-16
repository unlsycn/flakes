{
  config,
  lib,
  pkgs,
  user,
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
      zsh.enable = true;
      ssh.enable = true;
      git.enable = true;
      gpg.enable = true;
      neovim.enable = true;
      jq.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      direnv.enable = true;
      zoxide.enable = true;
      bat.enable = true;
      fd.enable = true;
      ripgrep.enable = true;
      nnn.enable = true;
    };

    services = {
      gpg-agent.enable = true;
      vscode-server.enable = true;
    };

    home.packages = with pkgs; [
      nixd
      tree
      tokei
      dust
      gotop
      axel
      rsync
      tldr
    ];

    persist."/persist".users.${user} = {
      directories = [
        ".local"
        ".cache"
      ];
    };
  };
}
