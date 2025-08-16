{ ... }:
{
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    printing.enable = true;
    libinput.enable = true;
    openssh.enable = true;
  };
}
