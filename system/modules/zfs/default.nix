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
    boot.initrd.systemd.mounts = [
      {
        wantedBy = [ "initrd.target" ];
        before = [ "initrd-nixos-activation.service" ];
        where = "/sysroot/etc/zfs/zfs-list.cache";
        what = "/sysroot/persist/etc/zfs/zfs-list.cache";
        unitConfig.DefaultDependencies = false;
        type = "none";
        options = concatStringsSep "," [
          "bind"
          "x-gvfs-hide"
        ];
      }
    ];
    systemd.services.zfs-mount.enable = false;
    assertions = [
      {
        assertion = config.boot.initrd.systemd.enable;
        message = "zfs mount generator requires systemd in initrd";
      }
    ];

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
