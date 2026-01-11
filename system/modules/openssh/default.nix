{
  config,
  lib,
  user,
  sshKeys,
  ...
}:
{
  config = lib.mkIf config.services.openssh.enable {
    environment.persistence."/persist" = {
      files = [
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };

    services.openssh.settings.PasswordAuthentication = false;
    users.users.${user}.openssh.authorizedKeys.keys = sshKeys;

    programs.ssh.startAgent = true;
  };
}
