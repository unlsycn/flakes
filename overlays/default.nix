{ lib, ... }:
with lib;
with builtins;
./.
|> readDir
|> filterAttrs (name: type: type == "directory")
|> mapAttrs (overlay: _: import ./${overlay} { inherit lib; })
