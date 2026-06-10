{
  config,
  lib,
  ...
}:
with lib;
{
  options = {
    hasGraphicalEnvironment = mkOption {
      type = types.bool;
      default = config.desktop.enable || config.handheld.enable;
      description = "Whether this host has any graphical environment.";
    };

    desktop.enable = mkEnableOption "desktop workstation environment";
  };

  config = mkMerge [
    (mkIf config.hasGraphicalEnvironment {
      services = {
        pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };
        printing.enable = true;
        libinput.enable = true;
        blueman.enable = true;
      };
    })
    (mkIf config.desktop.enable {
      programs.hyprland.enable = mkDefault true;
    })
  ];
}
