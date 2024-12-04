{ user, ... }:
{
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [
    {
      users = [ user ];
      keepEnv = true;
      persist = true;
    }
  ];
}
