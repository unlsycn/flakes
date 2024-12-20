{ ... }:
{
  imports = [
    ../modules/openssh
  ];

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    printing.enable = true;
    libinput.enable = true;
    openssh.enable = true;
  };
}
