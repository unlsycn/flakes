{
  lib,
  ...
}:
builtins.path {
  name = "brainstorming";
  path = ./.;
  filter = path: _type: lib.baseNameOf path != "default.nix";
}
