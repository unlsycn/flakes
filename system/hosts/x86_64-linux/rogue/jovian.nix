{ pkgs, user, ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = user;
      desktopSession = "gnome";
    };
    steamos.useSteamOSConfig = true;
    hardware.has.amd.gpu = true;
    decky-loader = {
      enable = true;
      user = user;
      extraPackages = with pkgs; [
        ryzenadj
      ];
    };
    devices.ally-z1e.enable = true;
  };

}
