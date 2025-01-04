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
    };

    persist."/persist".users.${user} = {
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };

    sops.secrets.ssh-key-public = {
      sopsFile = ./ssh-key.yaml.admin;
      key = "public";
      path = "${config.home.homeDirectory}/.ssh/id_unlsycn.pub";
    };
    sops.secrets.ssh-key-secret = {
      sopsFile = ./ssh-key.yaml.admin;
      key = "secret";
      path = "${config.home.homeDirectory}/.ssh/id_unlsycn";
    };
  };
}
