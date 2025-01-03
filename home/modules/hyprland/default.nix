{
  config,
  lib,
  inputs,
  system,
  ...
}:
with lib;
{
  imports = [
    ./general.nix
    ./env.nix
    ./bindings.nix
    ./rules.nix
  ];

  config = mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland = {
      package = inputs.hyprland.packages.${system}.hyprland;
      systemd.variables = [ "--all" ];
    };

    programs.zsh.profileExtra = ''
      if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] then
          Hyprland
      fi
    '';
  };
}
