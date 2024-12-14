{ ... }:
{
  imports = [
    ../modules/openssh
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.printing.enable = true;
  services.libinput.enable = true;
  services.openssh.enable = true;
}
