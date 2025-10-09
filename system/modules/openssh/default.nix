{
  config,
  lib,
  user,
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
    users.users.${user}.openssh.authorizedKeys.keyFiles = [
      ./id_ed25519.pub
      ./id_rsa.pub
    ];

    programs.ssh.startAgent = true;
  };
}
