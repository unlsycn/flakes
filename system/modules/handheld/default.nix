{
  config,
  lib,
  user,
  pkgs,
  inputs,
  ...
}:
with lib;
{
  imports = [ inputs.jovian-nixos.nixosModules.default ];

  options = {
    handheld = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          hhd.enable = mkOption {
            type = types.bool;
            default = false;
          };
        };
      };
      default = { };
    };
  };

  config = mkMerge [
    (mkIf config.handheld.enable {
      jovian = {
        steam = {
          enable = true;
          autoStart = true;
          user = user;
          desktopSession = "gnome";
          inputMethod = {
            # FIXME
            enable = false;
            methods = [ "pinyin" ];
          };
        };
        steamos.useSteamOSConfig = true;
        decky-loader = {
          enable = true;
          user = user;
          extraPackages = with pkgs; [
            ryzenadj
          ];
        };
      };

      # disable GNOME IBUS seervice to prevent DBUS collision
      systemd.user.services."org.freedesktop.IBus.session.GNOME".enable = false;
      systemd.user.services."org.freedesktop.IBus.session.generic".enable = false;

      # enable Steam CEF remote debugging for decky-loader
      systemd.tmpfiles.settings."steam-cef-remote-debugging"."${
        config.users.users.${user}.home
      }/.local/share/Steam/.cef-enable-remote-debugging".f =
        {
          user = user;
          group = "users";
        };
    })
    (mkIf config.handheld.hhd.enable {
      boot = lib.mkIf config.services.tlp.enable {
        kernelModules = [ "acpi_call" ];
        extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
      };
      services.handheld-daemon = {
        enable = true;
        user = user;
        ui.enable = true;
        adjustor = {
          enable = true;
          loadAcpiCallModule = true;
        };
      };
      # does not work with inputplumber
      services.inputplumber.enable = mkForce false;
      services.powerstation.enable = mkForce false;
      services.tuned.enable = mkForce false;
    })
  ];
}
