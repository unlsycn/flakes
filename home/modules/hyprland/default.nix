{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./general.nix
    ./env.nix
    ./bindings.nix
    ./rules.nix
    ./monitors.nix

    ./lib
  ];

  config = mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland = {
      systemd.variables = [ "--all" ];

      monitors = [
        "allay"
        "philips"
      ];
    };

    programs.zsh.profileExtra = ''
      if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] then
          start-hyprland
      fi
    '';
  };
}
