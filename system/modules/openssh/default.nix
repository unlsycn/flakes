{
  config,
  lib,
  user,
  sshKeys,
  ...
}:
let
  cfg = config.services.openssh;
in
{
  config = lib.mkIf cfg.enable {
    environment.persistence."/persist" = {
      files = [
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };

    services.openssh.settings.PasswordAuthentication = false;
    services.openssh.openFirewall = false;
    users.users.${user}.openssh.authorizedKeys.keys = sshKeys;

    programs.ssh.startAgent = true;

    mesh.surfaces = {
      public.allowedTCPPorts = cfg.ports;
      nebula.allowedTCPPorts = lib.mkIf config.mesh.nebula.enable cfg.ports;
      tailnet.allowedTCPPorts = lib.mkIf config.mesh.tailnet.enable cfg.ports;
    };
  };
}
