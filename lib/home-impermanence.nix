{ lib, ... }:
with lib;
{
  # workaround for https://github.com/nix-community/impermanence/issues/231
  # To keep the impermanence config together with the other configs for better cohesion, we define this option and merge it into nixosConfiguration in ../system/commom/impermanence.nix
  options.persist = mkOption { type = types.anything; };
}
