{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    zfs.package = pkgs.zfs_unstable;
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "virtio_pci"
        "virtio_blk"
        "virtio_scsi"
      ];
    };
    kernelParams = [
      # 1 GiB
      "zfs.zfs_arc_max=1073741824"
    ];
  };

  disko.devices = {
    disk.system-ssd = {
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          bios = {
            size = "1M";
            type = "EF02";
            attributes = [ 0 ];
            priority = 1;
          };

          boot = {
            label = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          swap = {
            size = "16G";
            content = {
              type = "swap";
              discardPolicy = "both";
            };
          };

          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "system";
            };
          };
        };
      };
    };

    zpool.system = {
      type = "zpool";
      rootFsOptions = {
        mountpoint = "none";
        acltype = "posixacl";
        relatime = "on";
        compression = "zstd";
        xattr = "sa";
      };
      options.ashift = "12";

      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        "nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.mountpoint = "legacy";
        };
        "foundryvtt" = {
          type = "zfs_fs";
          options = {
            mountpoint = "/var/lib/foundryvtt";
            atime = "off";
          };
        };
        "foundryvtt/Data/worlds" = {
          type = "zfs_fs";
          options."com.sun:auto-snapshot" = "true";
        };
        "headscale" = {
          type = "zfs_fs";
          options = {
            mountpoint = "/var/lib/headscale";
            atime = "off";
            "com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
