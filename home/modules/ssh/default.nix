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
      directories = [ ".ssh" ];
    };
  };
}
