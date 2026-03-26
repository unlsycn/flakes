final: prev:
with prev.lib;
with builtins;
genAttrs (./. |> readDir |> filterAttrs (_: type: type == "directory") |> attrNames) (
  name: final.callPackage ./${name} { }
)
