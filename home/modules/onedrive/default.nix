{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.onedrive;
  syncDir = "OneDrive";
in
{
  options.programs.onedrive = {
    persist = mkOption {
      type = types.bool;
      default = true;
    };
    monitor.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.onedrive.settings = {
      sync_dir = "~/${syncDir}";
      skip_file = "~*|.~*|*.tmp|*.lock|*.swp|*.partial|*desktop.ini";
    };

    home.persistence."/persist" = {
      directories = [
        ".config/onedrive"
      ]
      ++ optional cfg.persist syncDir;
    };

    xdg.configFile = {
      # NOTE: sync_list is a hard contract with the remote folder layout.
      # Anything not listed here is skipped, so a top-level rename done on another
      # client makes this client's database path diverge from its local disk. The
      # client's database-consistency pass then reads "path missing locally" as
      # "user deleted the file" and pushes that deletion to OneDrive.
      # Whenever a top-level entry changes, update this list AND restart the
      # service with --resync.
      "onedrive/sync_list".text =
        [
          "/Documents"
          "/Library"
          "/Music"
          "/Personal"
          "/Pictures"
        ]
        |> lib.concatStringsSep "\n";
    };

    home.file = {
      "Documents".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Documents";
      "Pictures".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Pictures";
      "Music".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/OneDrive/Music";
    };

    systemd.user.services.onedrive-monitor = mkIf cfg.monitor.enable {
      Unit.Description = "OneDrive Monitor";

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
        ExecStart = "${getExe cfg.package} --monitor";
        Restart = "on-failure";
        RestartSec = 3;
        RestartPreventExitStatus = 126;
        TimeoutStopSec = 90;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
