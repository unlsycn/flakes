{ user, ... }:
{
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        users = [ user ];
        keepEnv = true;
        persist = true;
      }
    ];
  };
}
