{
  config,
  lib,
  ...
}:
with lib;
let
  toLua = generators.toLua { };
in
{
  imports = [
    ./general.nix
    ./env.nix
    ./bindings.nix
    ./rules.nix
    ./monitors.nix
    ./execs.nix

    ./lib
  ];

  config = mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland = {
      configType = "lua";
      importantPrefixes = [
        "$"
        "env"
        "config"
        "curve"
        "monitor"
        "name"
        "output"
      ];
      systemd.variables = [ "--all" ];

      monitors = [
        "allay"
        "philips"
      ];

      settings.colors._var = mkIf (hasAttr "hypr/themes/catppuccin.lua" config.xdg.configFile) (
        mkForce (
          generators.mkLuaInline ''
            dofile((os.getenv("XDG_CONFIG_HOME") or ${toLua config.xdg.configHome}) .. "/hypr/themes/catppuccin.lua")
          ''
        )
      );
    };

    programs.zsh.profileExtra = ''
      if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]] then
          start-hyprland
      fi
    '';
  };
}
