{
  config,
  pkgs,
  user,
  ...
}:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = user;
      desktopSession = "gnome";
      inputMethod = {
        # FIXME
        enable = false;
        methods = [ "pinyin" ];
      };
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

  # disable GNOME IBUS seervice to prevent DBUS collision
  systemd.user.services."org.freedesktop.IBus.session.GNOME".enable = false;
  systemd.user.services."org.freedesktop.IBus.session.generic".enable = false;

  # enable Steam CEF remote debugging for decky-loader
  systemd.tmpfiles.settings."steam-cef-remote-debugging"."${
    config.users.users.${user}.home
  }/.local/share/Steam/.cef-enable-remote-debugging".f =
    {
      user = user;
      group = "users";
    };
}
