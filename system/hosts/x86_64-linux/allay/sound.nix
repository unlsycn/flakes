{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  systemWide = config.services.pipewire.systemWide;
  ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";
in
{
  environment = {
    systemPackages = with pkgs; [
      lnl-alsa-ucm-conf
    ];
    pathsToLink = [
      "/share/alsa"
    ];
  };

  systemd = {
    services.pipewire.environment.ALSA_CONFIG_UCM2 = mkIf systemWide ALSA_CONFIG_UCM2;
    services.wireplumber.environment.ALSA_CONFIG_UCM2 = mkIf systemWide ALSA_CONFIG_UCM2;
    user.services.pipewire.environment.ALSA_CONFIG_UCM2 = mkIf (!systemWide) ALSA_CONFIG_UCM2;
    user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = mkIf (!systemWide) ALSA_CONFIG_UCM2;
  };

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
}
