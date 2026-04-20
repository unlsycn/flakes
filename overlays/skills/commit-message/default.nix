{
  lib,
  ...
}:
builtins.path {
  name = "commit-message";
  path = ./.;
  filter = path: _type: lib.baseNameOf path != "default.nix";
}
