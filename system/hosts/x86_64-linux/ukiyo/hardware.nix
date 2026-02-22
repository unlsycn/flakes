{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    zfs = {
      package = pkgs.zfs_unstable;
    };

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
    kernelParams = [ "zfs.zfs_arc_max=1073741824" ];
  };

  disko.devices = {
    disk = {
      system-ssd = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              attributes = [ 0 ];
              priority = 1;
            };

            swap = {
              size = "4G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
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
    };

    zpool.system = {
      type = "zpool";
      rootFsOptions = {
        mountpoint = "none";
        acltype = "posixacl";
        relatime = "on";
        compression = "lz4";
        xattr = "sa";
      };
      options = {
        ashift = "12";
        autotrim = "on";
        # not compatible with zstd compression
        compatibility = "grub2";
      };

      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
