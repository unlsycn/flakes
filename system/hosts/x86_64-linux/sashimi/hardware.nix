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
  };

  disko.devices.disk.main = {
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
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  networking = {
    interfaces.eth0.useDHCP = true;
    usePredictableInterfaceNames = false;
  };
}
