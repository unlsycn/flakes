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
  # See home/modules/impermanence/default.nix
  # use mkIf for lazy evaluation
  config = mkIf (builtins.hasAttr "persist" homeConfig) {
    environment.persistence = homeConfig.persist;
  };
}
