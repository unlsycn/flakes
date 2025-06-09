{
  pkgs,
  ...
}:
let
  ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";
in
{
  environment.systemPackages = with pkgs; [
    lnl-alsa-ucm-conf
  ];
  environment.pathsToLink = [
    "/share/alsa"
  ];
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = ALSA_CONFIG_UCM2;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = ALSA_CONFIG_UCM2;

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
}
