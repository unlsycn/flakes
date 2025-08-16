{
  config,
  pkgs,
  lib,
  ...
}:
{
  # workaround for https://github.com/NixOS/nix/issues/10202
  systemd.tmpfiles.settings."root-gitconfig"."/root/.gitconfig".L = {
    user = "root";
    group = "root";
    argument = "${pkgs.writeText "root-gitconfig" ''
      [safe]
        directory = /home/unlsycn/.nix
        directory = /home/unlsycn/.cache/nix/tarball-cache
    ''}";
  };

  # workaround for https://github.com/NixOS/nixpkgs/issues/6481
  systemd.tmpfiles.rules = lib.concatLists (
    lib.mapAttrsToList (
      _: user:
      lib.optionals user.createHome [
        "d ${lib.escapeShellArg user.home} ${user.homeMode} ${user.name} ${user.group}"
      ]
    ) config.users.users
  );
}
