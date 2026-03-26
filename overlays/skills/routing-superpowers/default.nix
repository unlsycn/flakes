{
  lib,
  ...
}:
builtins.path {
  name = "routing-superpowers";
  path = ./.;
  filter = path: _type: lib.baseNameOf path != "default.nix";
}
