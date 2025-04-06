{ lib, ... }:
with lib;
{
  # workaround for https://github.com/nix-community/impermanence/issues/231
  # To keep the impermanence config together with the other configs for better cohesion, we define this option and merge it into nixosConfiguration in /system/commom/impermanence.nix
  options.persist = mkOption {
    type =
      with types;
      let
        # use valueType instead of anything to merge lists correctly
        valueType = nullOr (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ]);
      in
      valueType;
  };
}
