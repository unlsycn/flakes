{ lib, ... }:
with lib;
with builtins;
let
  packageList = attrNames (filterAttrs (name: type: type == "directory") (readDir ./.));
in
{
  nixpkgs.overlays = [
    (self: super: genAttrs packageList (name: self.callPackage ./${name} { }))
  ];
}
