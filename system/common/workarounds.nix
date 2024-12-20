{ config, lib, ... }:
{
  # workaround for https://github.com/NixOS/nix/issues/10202
  environment.persistence."/persist".files = [ "/root/.gitconfig" ];

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
