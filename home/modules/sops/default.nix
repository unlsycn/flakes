{
  config,
  user,
  ...
}:
{
  sops.age.keyFile = "${config.xdg.configHome}/age/key";

  # sops require gnupg passphrase
  systemd.user.services.sops-nix.Service = {
    Restart = "on-failure";
    RestartSec = "5s";
  };

  persist."/persist".users.${user}.files = [ ".config/age/key" ];
}
