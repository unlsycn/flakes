{
  config,
  lib,
  user,
  ...
}:
with lib;
let
  homeConfig = config.home-manager.users.${user};
in
{
  # See ../../lib/home-impermanence.nix
  # use mkIf for lazy evaluation
  config = mkIf (builtins.hasAttr "persist" homeConfig) {
    environment.persistence = homeConfig.persist;
  };
}
