{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.sops;
in
{
  options.sops.admin = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        let
          groupName = name;
        in
        {
          options = {
            sopsFile = mkOption {
              type = types.path;
              description = "SOPS file containing the group's secrets.";
            };

            secrets = mkOption {
              type = types.attrsOf (
                types.submodule (
                  { name, ... }:
                  {
                    options = {
                      key = mkOption {
                        type = types.str;
                        default = if cfg.defaultSopsKey != null then cfg.defaultSopsKey else name;
                        description = "Key used to look up the secret in the SOPS file.";
                      };

                      path = mkOption {
                        type = types.str;
                        default = "${config.xdg.configHome}/sops-nix/admin/${groupName}/${name}";
                        description = "Path where the decrypted secret is symlinked.";
                      };

                      format = mkOption {
                        type = types.enum [
                          "yaml"
                          "json"
                          "binary"
                          "ini"
                          "dotenv"
                        ];
                        default = cfg.defaultSopsFormat;
                        defaultText = literalExpression "config.sops.defaultSopsFormat";
                        description = "File format used to decrypt the secret.";
                      };

                      mode = mkOption {
                        type = types.str;
                        default = "0400";
                        description = "Permissions mode of the secret file in octal.";
                      };
                    };
                  }
                )
              );
              default = { };
              description = "Secrets deployed by this independent admin service.";
            };
          };
        }
      )
    );
    default = { };
    description = ''
      Secret groups deployed through independent sops-install-secrets user services.
    '';
  };

  config =
    let
      adminGroups = cfg.admin |> filterAttrs (_: group: group.secrets != { });

      manifestFor =
        name: group:
        pkgs.writeTextFile {
          name = "manifest-admin-${name}.json";
          text = builtins.toJSON {
            secrets = mapAttrsToList (
              secretName: secret:
              secret
              // {
                name = secretName;
                sopsFile = group.sopsFile;
              }
            ) group.secrets;
            templates = [ ];
            secretsMountPoint = "%r/sops-nix-admin-${name}.d";
            symlinkPath = "${config.xdg.configHome}/sops-nix/admin/${name}";
            keepGenerations = cfg.keepGenerations;
            gnupgHome = cfg.gnupg.home;
            sshKeyPaths = cfg.gnupg.sshKeyPaths;
            ageKeyFile = cfg.age.keyFile;
            ageSshKeyPaths = cfg.age.sshKeyPaths;
            placeholderBySecretName = { };
            userMode = true;
            logging = {
              keyImport = elem "keyImport" cfg.log;
              secretChanges = elem "secretChanges" cfg.log;
            };
          };
          checkPhase = ''
            ${getExe' cfg.package "sops-install-secrets"} -check-mode=${
              if cfg.validateSopsFiles then "sopsfile" else "manifest"
            } "$out"
          '';
        };

      serviceName = name: "sops-nix-admin-${name}";

    in
    mkIf (adminGroups != { }) {
      assertions = [
        {
          assertion =
            cfg.gnupg.home != null
            || cfg.gnupg.sshKeyPaths != [ ]
            || cfg.age.keyFile != null
            || cfg.age.sshKeyPaths != [ ];
          message = "No key source configured for sops.admin. Set sops.gnupg.home, sops.gnupg.sshKeyPaths, sops.age.keyFile or sops.age.sshKeyPaths";
        }
      ];

      systemd.user.services = mapAttrs' (
        name: group:
        nameValuePair (serviceName name) {
          Unit = {
            Description = "sops-nix admin secrets (${name})";
            After = [ "sops-nix.service" ];
          };
          Service = {
            Type = "oneshot";
            Environment = concatStringsSep " " (
              mapAttrsToList (envName: value: "'${envName}=${value}'") cfg.environment
            );
            ExecStart = pkgs.writeShellScript (serviceName name) ''
              exec ${getExe' cfg.package "sops-install-secrets"} -ignore-passwd ${manifestFor name group}
            '';
            Restart = "on-failure";
            RestartSec = "5s";
          };
          Install.WantedBy =
            if cfg.gnupg.home != null then [ "graphical-session-pre.target" ] else [ "default.target" ];
        }
      ) adminGroups;

      home.activation = mapAttrs' (
        name: _:
        nameValuePair (serviceName name) (
          hm.dag.entryAfter [ "reloadSystemd" ] ''
            systemdStatus=$(${config.systemd.user.systemctlPath} --user is-system-running 2>&1 || true)

            if [[ $systemdStatus == 'running' || $systemdStatus == 'degraded' ]]; then
              ${config.systemd.user.systemctlPath} --user restart ${serviceName name}.service \
                || echo "Warning: sops-nix admin group ${name} failed to deploy; ordinary secrets are unaffected." >&2
            else
              echo "User systemd daemon not running. Admin group ${name} will be installed at login."
            fi

            unset systemdStatus
          ''
        )
      ) adminGroups;
    };
}
