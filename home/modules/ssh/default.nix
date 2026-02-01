{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.programs.ssh.enable {
    programs.ssh = {
      enableDefaultConfig = false;
      includes = [ "hosts_config" ];
      matchBlocks."*" = {
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
        identityFile = mkIf config.sops.control.deploySshSecrets [
          config.sops.secrets.ssh-ed25519-secret.path
          config.sops.secrets.ssh-rsa-secret.path
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

    sops.secrets = mkIf config.sops.control.deploySshSecrets {
      ssh-ed25519-public = {
        sopsFile = ./ssh-key.yaml.admin;
        key = "ed25519-public";
        path = "${config.home.homeDirectory}/.ssh/id_unlsycn.pub";
      };
      ssh-ed25519-secret = {
        sopsFile = ./ssh-key.yaml.admin;
        key = "ed25519-secret";
        path = "${config.home.homeDirectory}/.ssh/id_unlsycn";
      };
      ssh-rsa-public = {
        sopsFile = ./ssh-key.yaml.admin;
        key = "rsa-public";
        path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
      };
      ssh-rsa-secret = {
        sopsFile = ./ssh-key.yaml.admin;
        key = "rsa-secret";
        path = "${config.home.homeDirectory}/.ssh/id_rsa";
      };
    };
  };
}
