{ ... }:
{
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        keepEnv = true;
        persist = true;
      }
    ];
  };
}
