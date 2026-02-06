{
  config,
  pkgs,
  user,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    zfs.package = pkgs.zfs_unstable;
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = config.disko.devices.disk.main.content.partitions.esp.content.mountpoint;
      };
      systemd-boot = {
        enable = true;
        xbootldrMountPoint = config.disko.devices.disk.main.content.partitions.boot.content.mountpoint;
        extraInstallCommands = "${pkgs.coreutils}/bin/install -D -m0755 ${pkgs.refind}/share/refind/drivers_x64/* -t ${config.boot.loader.efi.efiSysMountPoint}/EFI/systemd/driver";
      };
      timeout = 1;
    };
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      # 2 GiB
      "zfs.zfs_arc_max=2147483648"
      # 1 GiB
      "zfs.zfs_arc_min=1073741824"
    ];
    kernel.sysctl."kernel.sysrq" = 246;
  };

  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-WD_PC_SN560_SDDPNQE-1T00-1102_24381G804308";
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
                mountpoint = "/efi";
                mountOptions = [ "umask=0077" ];
              };
            };
            boot = {
              label = "boot";
              size = "4G";
              type = "EA00";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            swap = {
              label = "swap";
              size = "32G";
              content = {
                type = "swap";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "allay";
              };
            };
          };
        };
      };
    };
    zpool = {
      allay = {
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
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "safe" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
            };
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
            };
          };
          "local/onedrive" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/${user}/OneDrive";
              "com.sun:auto-snapshot" = "false";
            };
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "mode=755"
          "size=25%"
        ];
      };
    };
  };
  fileSystems = {
    # A race condition existed between mounting the stateless /home and bind mounting the persistent directories
    # Although we could utilize the ZFS mount generator to convert all ZFS mountings into systemd mount units and rely on systemd to handle the mount ordering
    # the impermanence executes a create-directories script as part of the stage 2 activation script, before systemd starts, to fix ownership and permissions of the parent directories of mount points
    # Therefore, we still need to mount /home before this step, so we mark it as needed for boot
    "/home".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
    firmware = with pkgs; [
      lnl-bt-firmware
    ];
  };
}
