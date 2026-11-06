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
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = config.disko.devices.disk.main.content.partitions.esp.content.mountpoint;
      };
      systemd-boot = {
        enable = true;
        xbootldrMountPoint = config.disko.devices.disk.main.content.partitions.boot.content.mountpoint;
        extraInstallCommands = lib.getExe (
          pkgs.writeShellApplication {
            name = "install-systemd-boot";
            runtimeInputs = with pkgs; [
              coreutils
              sbctl
            ];
            text = ''
              install -D -m0755 ${pkgs.refind}/share/refind/drivers_x64/* -t ${config.boot.loader.efi.efiSysMountPoint}/EFI/systemd/drivers

              efi=${lib.escapeShellArg config.boot.loader.efi.efiSysMountPoint}
              boot=${lib.escapeShellArg config.boot.loader.systemd-boot.xbootldrMountPoint}
              for image in \
                "$efi/EFI/systemd/systemd-bootx64.efi" \
                "$efi/EFI/BOOT/BOOTX64.EFI" \
                "$efi"/EFI/systemd/drivers/*.efi \
                "$boot"/EFI/nixos/*-${config.system.boot.loader.kernelFile}.efi
              do
                [ -e "$image" ] || continue
                sbctl --disable-landlock sign -s "$image"
              done
            '';
          }
        );
        editor = false;
      };
      timeout = 1;
    };
    initrd = {
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
      # 4 GiB
      "zfs.zfs_arc_max=4294967296"
      # 1 GiB
      "zfs.zfs_arc_min=1073741824"
    ];
    kernel.sysctl."kernel.sysrq" = 246;
  };

  sops.secrets =
    lib.mapAttrs'
      (
        key: path:
        lib.nameValuePair "sbctl-${lib.replaceStrings [ "/" ] [ "-" ] key}" {
          sopsFile = ./secureboot.yaml;
          inherit key;
          path = "/var/lib/sbctl/${path}";
        }
      )
      {
        GUID = "GUID";
        "keys/PK/key" = "keys/PK/PK.key";
        "keys/PK/pem" = "keys/PK/PK.pem";
        "keys/KEK/key" = "keys/KEK/KEK.key";
        "keys/KEK/pem" = "keys/KEK/KEK.pem";
        "keys/db/key" = "keys/db/db.key";
        "keys/db/pem" = "keys/db/db.pem";
      };

  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-ZHITAI_TiPlus7100_2TB_ZTA42T0BA2323376W6";
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
                discardPolicy = "once";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "hyperion";
              };
            };
          };
        };
      };
    };
    zpool = {
      hyperion = {
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

  systemd.network.links = {
    "10-lan0" = {
      matchConfig.PermanentMACAddress = "fc:9d:05:c1:e5:0f";
      linkConfig = {
        Name = "lan0";
        NamePolicy = "";
      };
    };

    "10-wlan0" = {
      matchConfig.PermanentMACAddress = "fc:9e:53:8d:37:e0";
      linkConfig = {
        Name = "wlan0";
        NamePolicy = "";
      };
    };
  };

  mesh.surfaces.public.interfaces = [
    config.systemd.network.links."10-lan0".linkConfig.Name
    config.systemd.network.links."10-wlan0".linkConfig.Name
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
  };
}
