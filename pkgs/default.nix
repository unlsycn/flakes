{ lib, ... }:
with lib;
with builtins;
let
  packageList = ./. |> readDir |> filterAttrs (name: type: type == "directory") |> attrNames;
in
self: super: genAttrs packageList (name: self.callPackage ./${name} { })
