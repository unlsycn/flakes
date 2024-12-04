{ ... }:
{
  imports = [
    ../modules/openssh
    ../modules/vscode-server
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.printing.enable = true;
  services.libinput.enable = true;
  services.vscode-server.enable = true;
  services.openssh.enable = true;
}
