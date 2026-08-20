{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      timeout = 1;
    };
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
    disk.main = {
      device = "/dev/disk/by-id/virtio-uf64mkj3hfc8hvnkcn2p";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
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
      };
    };
  };

  networking = {
    interfaces.eth0.useDHCP = true;
    usePredictableInterfaceNames = false;
  };
}
