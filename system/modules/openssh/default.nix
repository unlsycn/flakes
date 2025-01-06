{ config, lib, ... }:
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

    programs.ssh.startAgent = true;
  };
}
