{ ... }:

{
  imports = [ ./options.nix ];

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
}
