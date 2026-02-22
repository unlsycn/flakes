{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    supportedFilesystems = [ "zfs" ]; # no zfs partitions in config.fileSystems so enable manually
    zfs = {
      package = pkgs.zfs_unstable;
      extraPools = [ "data" ];
    };
    loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "xen_blkfront"
        "vmw_pvscsi"
      ];
      kernelModules = [ "nvme" ];
    };
    kernelParams = [
      # 1 GiB
      "zfs.zfs_arc_max=1073741824"
    ];
  };

  disko.devices = {
    disk = {
      system-ssd = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "root";
              start = "2M";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];
        };
      };
      data-ssd = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "data";
            };
          };
        };
      };
    };

    zpool.data = {
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
        "foundryvtt" = {
          type = "zfs_fs";
          options = {
            mountpoint = "/var/lib/foundryvtt";
            atime = "off";
            "com.sun:auto-snapshot" = "false";
          };
        };
        "foundryvtt/Data/worlds" = {
          type = "zfs_fs";
          options."com.sun:auto-snapshot" = "true";
        };
        "nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16384;
    }
  ];
}
