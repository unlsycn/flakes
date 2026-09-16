{ ... }:
{
  programs.mosh.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 19722 ];
  };
}
