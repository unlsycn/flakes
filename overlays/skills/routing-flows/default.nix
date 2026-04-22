{
  lib,
  ...
}:
builtins.path {
  name = "routing-flows";
  path = ./.;
  filter = path: _type: lib.baseNameOf path != "default.nix";
}
