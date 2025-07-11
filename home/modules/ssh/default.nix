{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  config = mkIf config.programs.ssh.enable {
    programs.ssh = {
      forwardAgent = true;
      addKeysToAgent = "yes";
      includes = [ "hosts_config" ];
      matchBlocks."*".identityFile = [
        config.sops.secrets.ssh-ed25519-secret.path
        config.sops.secrets.ssh-rsa-secret.path
      ];
    };

    persist."/persist".users.${user} = {
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };

    sops.secrets.ssh-ed25519-public = {
      sopsFile = ./ssh-key.yaml.admin;
      key = "ed25519-public";
      path = "${config.home.homeDirectory}/.ssh/id_unlsycn.pub";
    };
    sops.secrets.ssh-ed25519-secret = {
      sopsFile = ./ssh-key.yaml.admin;
      key = "ed25519-secret";
      path = "${config.home.homeDirectory}/.ssh/id_unlsycn";
    };
    sops.secrets.ssh-rsa-public = {
      sopsFile = ./ssh-key.yaml.admin;
      key = "rsa-public";
      path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
    };
    sops.secrets.ssh-rsa-secret = {
      sopsFile = ./ssh-key.yaml.admin;
      key = "rsa-secret";
      path = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };
}
