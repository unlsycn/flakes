{
  config,
  lib,
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

    home.persistence."/persist" = {
      directories = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
      ];
    };
  };
}
