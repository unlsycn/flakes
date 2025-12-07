{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.zfs.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.services.zfs.enable {
    # generate mount units from zfs-list.cache
    systemd.generators."zfs-mount-generator" =
      "${config.boot.zfs.package}/lib/systemd/system-generator/zfs-mount-generator";
    # keep metadatas of datasets in zfs-list.cache up to date
    environment.etc."zfs/zed.d/history_event-zfs-list-cacher.sh".source =
      "${config.boot.zfs.package}/etc/zfs/zed.d/history_event-zfs-list-cacher.sh";
    # mountpoint cache is needed for boot for mount generator to use
    environment.persistence."/persist" = {
      directories = [ "/etc/zfs/zfs-list.cache" ];
      files = [ "/etc/zfs/zpool.cache" ];
    };
    fileSystems."/etc/zfs/zfs-list.cache".neededForBoot = true;
    systemd.services.zfs-mount.enable = false;

    services.zfs = {
      zed.settings.PATH = mkForce (
        makeBinPath (
          with pkgs;
          [
            diffutils
            config.boot.zfs.package
            coreutils
            curl
            gawk
            gnugrep
            gnused
            nettools
            util-linux
          ]
        )
      );

      autoSnapshot.enable = true;
      autoScrub.enable = true;
    };
  };

}
