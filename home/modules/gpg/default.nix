{
  config,
  lib,
  user,
  ...
}:
with lib;
{
  imports = [ ./agent.nix ];

  config = mkIf config.programs.gpg.enable {
    programs.gpg.publicKeys = [
      {
        source = ./unlsycn.pub;
        trust = 5;
      }
    ];

    persist."/persist".users.${user} = {
      directories = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
      ];
    };
  };
}
