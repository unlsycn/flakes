{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.mesh;
  tcfg = cfg.tailnet;
  hsCfg = config.services.headscale;

  dataDir = "/var/lib/headscale";
  policyDir = "${dataDir}/policy.d";
  policyPath = "${dataDir}/policy.hujson";
  extraRecordsPath = "${dataDir}/extra-records.json";

  tailnetServiceIntent =
    inputs.self.mesh-topology
    |> filterAttrs (_: host: host ? tailnet.client)
    |> mapAttrsToList (
      hostName: host:
      host.services
      |> filterAttrs (_: svc: svc.exposure.tailnet)
      |> mapAttrsToList (
        serviceName: _: {
          name = "${serviceName}.${cfg.tailnet.domain}";
          endpoint = hostName;
        }
      )
    )
    |> flatten;

  staticPolicy = {
    tagOwners = genAttrs [
      "tag:infra"
      "tag:friends-accessible"
      "tag:peer-relay"
      "tag:subnet-router"
    ] (_: [ "group:admins" ]);

    grants = [
      {
        src = [ "autogroup:member" ];
        dst = [ "autogroup:self" ];
        ip = [ "*" ];
      }
      {
        src = [ "group:admins" ];
        dst = [ "tag:infra" ];
        ip = [ "tcp:22" ];
      }
      {
        src = [ "group:admins" ];
        dst = [
          "tag:infra"
          "tag:friends-accessible"
        ];
        ip = [
          "tcp:80"
          "tcp:443"
        ];
      }
      {
        src = [ "group:friends" ];
        dst = [ "tag:friends-accessible" ];
        ip = [
          "tcp:80"
          "tcp:443"
        ];
      }
      {
        src = [
          "group:admins"
          "group:friends"
        ];
        dst = [ "tag:peer-relay" ];
        app."tailscale.com/cap/relay" = [ ];
      }
    ];
  };
in
{
  config = mkIf tcfg.server.enable {
    assertions = [
      {
        assertion = versionAtLeast hsCfg.package.version "0.29.2";
        message = "Headscale Tailnet policy grants and Peer Relay require headscale 0.29.2 or newer";
      }
      {
        assertion =
          let
            names = map (service: toLower service.name) tailnetServiceIntent;
          in
          length names == length (unique names);
        message = "Tailnet service names must be globally unique across mesh hosts";
      }
    ];

    services.headscale = {
      enable = true;
      settings = {
        server_url = "https://${tcfg.controlHost}";
        trusted_proxies = [ "127.0.0.1/32" ];
        prefixes = tcfg.prefixes;
        dns = {
          magic_dns = true;
          # Headscale owns this suffix through extra_records_path:
          # https://github.com/juanfont/headscale/issues/3070
          # https://github.com/juanfont/headscale/issues/3316
          base_domain = tcfg.domain;
          override_local_dns = false;
          nameservers.split = { };
          extra_records_path = extraRecordsPath;
        };
        derp.server.enabled = false;
        policy = {
          mode = "file";
          path = policyPath;
        };
      };
    };

    mesh.services.headscale = {
      exposure.public = true;
      publicDomain = tcfg.controlHost;
      locations."/" = {
        proxyPass = "http://${hsCfg.address}:${toString hsCfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header True-Client-IP "";
          proxy_set_header X-Real-IP "";
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          proxy_buffering off;
        '';
      };
    };

    environment.persistence."/persist".directories = [ dataDir ];

    systemd.services.headscale-policy-render =
      let
        initialPolicyFragments = {
          membership = {
            groups = genAttrs [
              "group:admins"
              "group:friends"
              "group:guests"
            ] (_: [ ]);
          };
          sessions = {
            groups = { };
            grants = [ ];
          };
        };

        policyRenderer = pkgs.writeShellApplication {
          name = "headscale-policy-render";
          runtimeInputs = [
            pkgs.coreutils
            hsCfg.package
          ];
          text = ''
            policy_dir="$1"
            output="$2"
            state_dir=$(dirname "$output")

            install -d -m 0750 "$policy_dir"

            membership="$policy_dir/membership.hujson"
            sessions="$policy_dir/sessions.hujson"

            seed_fragment() (
              target="$1"
              content="$2"

              if [ -e "$target" ] || [ -L "$target" ]; then
                exit 0
              fi

              tmp=$(mktemp "$policy_dir/.''${target##*/}.tmp.XXXXXX")
              trap 'rm -f "$tmp"' EXIT
              printf '%s\n' "$content" > "$tmp"
              chmod 0640 "$tmp"

              if ! ln -T "$tmp" "$target" 2>/dev/null; then
                if [ -e "$target" ] || [ -L "$target" ]; then
                  exit 0
                fi
                echo "headscale-policy-render: failed to initialize $target" >&2
                exit 1
              fi

              rm -f "$tmp"
              trap - EXIT
            )

            seed_fragment "$membership" ${escapeShellArg (builtins.toJSON initialPolicyFragments.membership)}
            seed_fragment "$sessions" ${escapeShellArg (builtins.toJSON initialPolicyFragments.sessions)}

            tmp=$(mktemp "$state_dir/policy.hujson.tmp.XXXXXX")
            trap 'rm -f "$tmp"' EXIT

            if ! ${
              pkgs.writers.writePython3 "headscale-policy-merge"
                {
                  libraries = [ pkgs.python3Packages.hjson ];
                }
                ''
                  import hjson
                  import json
                  import sys


                  def merge(target, source, fragment_path, path=()):
                      for key, incoming in source.items():
                          current_path = (*path, key)

                          if key not in target:
                              target[key] = incoming
                              continue

                          existing = target[key]
                          if isinstance(existing, dict) and isinstance(incoming, dict):
                              merge(existing, incoming, fragment_path, current_path)
                          elif isinstance(existing, list) and isinstance(incoming, list):
                              existing.extend(incoming)
                          elif type(existing) is not type(incoming) or existing != incoming:
                              location = ".".join(current_path)
                              raise SystemExit(f"{fragment_path}: conflicting {location}")


                  policy = {}

                  for path in sys.argv[1:]:
                      with open(path, encoding="utf-8") as fh:
                          fragment = hjson.load(fh)

                      if not isinstance(fragment, dict):
                          raise SystemExit(
                              f"{path}: top-level policy fragment must be an object"
                          )

                      merge(policy, fragment, path)

                  print(json.dumps(policy, indent=2, sort_keys=True))
                ''
            } ${pkgs.writeText "headscale-static-policy.json" (builtins.toJSON staticPolicy)} "$membership" "$sessions" > "$tmp"; then
              echo "headscale-policy-render: failed to merge policy fragments" >&2
              exit 1
            fi

            policy_check_args=()
            if ! ${systemctl} -q is-active headscale.service; then
              policy_check_args+=(--bypass-grpc-and-access-database-directly)
            fi

            if ! headscale \
              --config ${hsCfg.configFile} \
              --force policy check \
              "''${policy_check_args[@]}" \
              -f "$tmp"
            then
              echo "headscale-policy-render: rendered policy is invalid" >&2
              exit 1
            fi

            chmod 0440 "$tmp"
            mv -T "$tmp" "$output"
            trap - EXIT
          '';
        };
        systemctl = getExe' pkgs.systemd "systemctl";
        reloadHeadscale = pkgs.writeShellScript "headscale-policy-reload" ''
          if ${systemctl} -q is-active headscale.service; then
            exec ${systemctl} --no-block reload headscale.service
          fi
        '';
      in
      {
        description = "Render Headscale file policy from static and runtime fragments";
        before = [ "headscale.service" ];
        wantedBy = [ "headscale.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = hsCfg.user;
          Group = hsCfg.group;
          StateDirectory = "headscale";
          StateDirectoryMode = "0750";
          ExecStartPost = "+${reloadHeadscale}";
        };
        script = ''
          ${policyRenderer}/bin/headscale-policy-render ${policyDir} ${policyPath}
        '';
      };

    systemd.services.headscale = {
      preStart = ''
        if [ ! -f ${extraRecordsPath} ]; then
          printf '[]\n' > ${extraRecordsPath}
          chmod 0440 ${extraRecordsPath}
        fi

        test -s ${policyPath}
        ${getExe hsCfg.package} --config ${hsCfg.configFile} --force policy check \
          --bypass-grpc-and-access-database-directly \
          -f ${policyPath}
      '';
      # Headscale reloads its file policy, but not the rest of its configuration, on SIGHUP:
      # https://headscale.net/stable/ref/policy/
      serviceConfig.ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
    };

    systemd.services.headscale-extra-records-reconcile =
      let
        conflictStatus = 2;
        extraRecordsReconciler = pkgs.writeShellApplication {
          name = "headscale-extra-records-reconcile";
          runtimeInputs = [
            pkgs.coreutils
            hsCfg.package
          ];
          text = ''
            nodes=$(mktemp)
            records=$(mktemp ${extraRecordsPath}.tmp.XXXXXX)
            trap 'rm -f "$nodes" "$records"' EXIT

            headscale --config ${hsCfg.configFile} nodes list --output json > "$nodes"

            render_status=0
            ${
              pkgs.writers.writePython3 "headscale-extra-records-render" { } ''
                import json
                import sys
                from dataclasses import dataclass
                from ipaddress import ip_address
                from time import time_ns


                intent_path, nodes_path, domain = sys.argv[1:]

                with open(intent_path, encoding="utf-8") as fh:
                    intent = json.load(fh)
                with open(nodes_path, encoding="utf-8") as fh:
                    nodes = json.load(fh)

                if nodes is None:
                    nodes = []

                suffix = "." + domain.lower()
                now = time_ns()


                @dataclass(frozen=True)
                class RuntimeNode:
                    addresses: tuple
                    expired: bool


                def is_expired(node):
                    expiry = node.get("expiry")
                    if expiry is None:
                        return False

                    return (
                        expiry.get("seconds", 0) * 1_000_000_000
                        + expiry.get("nanos", 0)
                        < now
                    )


                nodes_by_name = {}
                for node in nodes:
                    name = node["given_name"].lower()
                    nodes_by_name[name] = RuntimeNode(
                        addresses=tuple(
                            ip_address(address) for address in node["ip_addresses"]
                        ),
                        expired=is_expired(node),
                    )


                records = []
                has_conflicts = False
                for service in intent:
                    service_name = service["name"].lower()
                    leaf = service_name.removesuffix(suffix)

                    if leaf in nodes_by_name:
                        has_conflicts = True
                        print(
                            f"omit {service_name}: service name collides with "
                            "a runtime Headscale node name",
                            file=sys.stderr,
                        )
                        continue

                    endpoint = service["endpoint"].lower()
                    runtime_node = nodes_by_name.get(endpoint)
                    if runtime_node is None:
                        print(
                            f"omit {service_name}: endpoint {endpoint} is not registered",
                            file=sys.stderr,
                        )
                        continue

                    if runtime_node.expired:
                        print(
                            f"omit {service_name}: endpoint {endpoint} is expired",
                            file=sys.stderr,
                        )
                        continue

                    for address in runtime_node.addresses:
                        records.append(
                            {
                                "name": service_name,
                                "type": "A" if address.version == 4 else "AAAA",
                                "value": str(address),
                            }
                        )

                records.sort(
                    key=lambda item: (item["name"], item["type"], item["value"])
                )
                json.dump(records, sys.stdout, indent=2, sort_keys=True)
                print()

                if has_conflicts:
                    raise SystemExit(${toString conflictStatus})
              ''
            } ${pkgs.writeText "headscale-tailnet-service-intent.json" (builtins.toJSON tailnetServiceIntent)} "$nodes" "${cfg.tailnet.domain}" > "$records" \
              || render_status=$?

            if [ "$render_status" -eq 0 ] || [ "$render_status" -eq ${toString conflictStatus} ]; then
              chmod 0440 "$records"
              mv -T "$records" ${extraRecordsPath}
            fi

            exit "$render_status"
          '';
        };
      in
      {
        description = "Reconcile Headscale extra DNS records from static mesh Tailnet intent";
        requisite = [ "headscale.service" ];
        after = [ "headscale.service" ];
        partOf = [ "headscale.service" ];
        wantedBy = [ "headscale.service" ];
        unitConfig = {
          StartLimitIntervalSec = "30s";
          StartLimitBurst = 3;
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartPreventExitStatus = toString conflictStatus;
          RestartSec = "5s";
          User = hsCfg.user;
          Group = hsCfg.group;
        };
        script = ''
          ${extraRecordsReconciler}/bin/headscale-extra-records-reconcile
        '';
      };

  };
}
