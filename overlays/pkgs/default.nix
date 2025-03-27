final: prev:
with prev.lib;
with builtins;
let
  packageList = ./. |> readDir |> filterAttrs (name: type: type == "directory") |> attrNames;
in
genAttrs packageList (name: final.callPackage ./${name} { })
