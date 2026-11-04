{
  config,
  lib,
  ...
}:
with lib;
let
  deploySshSecrets = config.sops.control.deploySecrets && config.sops.control.deploySshSecrets;
in

{
  config = mkIf config.programs.ssh.enable {
    programs.ssh = {
      enableDefaultConfig = false;
      includes = [ "hosts_config" ];
      settings."*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        identityFile = mkIf deploySshSecrets [
          config.sops.admin.ssh.secrets.ssh-ed25519-secret.path
          config.sops.admin.ssh.secrets.ssh-rsa-secret.path
        ];
      };
    };

    home.persistence."/persist" = {
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };

    sops.admin.ssh = mkIf deploySshSecrets {
      sopsFile = ./ssh-key.yaml.admin;
      secrets = {
        ssh-ed25519-public = {
          key = "ed25519-public";
          path = "${config.home.homeDirectory}/.ssh/id_unlsycn.pub";
        };
        ssh-ed25519-secret = {
          key = "ed25519-secret";
          path = "${config.home.homeDirectory}/.ssh/id_unlsycn";
        };
        ssh-rsa-public = {
          key = "rsa-public";
          path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
        };
        ssh-rsa-secret = {
          key = "rsa-secret";
          path = "${config.home.homeDirectory}/.ssh/id_rsa";
        };
      };
    };
  };
}
