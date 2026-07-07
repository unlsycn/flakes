{ lib, pkgs }:
{
  mkMutableGeneratedFile = import ./mutable-generated-file.nix { inherit lib pkgs; };
}
