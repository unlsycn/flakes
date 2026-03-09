{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.deskflow;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    services.deskflow = {
      server = {
        enable = true;
        config = {
          screens = {
            allay = { };
            artanis = { };
          };

          aliases = { };

          options = {
            switchDoubleTap = 250;
          };

          links = {
            allay = {
              left = [
                {
                  screen = "artanis";
                  srcStart = 5;
                  srcEnd = 100;
                }
              ];
            };
            artanis = {
              right = "allay";
            };
          };
        };
      };
    };
  };
}
