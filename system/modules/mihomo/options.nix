{ config, lib, ... }:

with lib;
with types;
let
  cfg = config.services.mihomo;
in
{
  options.services.mihomo = {
    proxyProviders = mkOption {
      type = attrsOf (submodule {
        options = {
          type = mkOption {
            type = enum [
              "http"
              "file"
              "inline"
            ];
          };
        };
      });
    };
    ruleProviders = mkOption {
      type = attrsOf (submodule {
        options = {
          type = mkOption {
            type = enum [
              "http"
              "file"
              "inline"
            ];
          };
          behavior = mkOption {
            type = enum [
              "domain"
              "ipcidr"
              "classical"
            ];
          };
          url = mkOption {
            type = nullOr str;
          };
        };
      });
    };
    regions = mkOption {
      type = attrsOf (submodule {
        options = {
          filter = mkOption {
            type = str;
          };
        };
      });
    };
    routes = mkOption {
      type = attrsOf (
        listOf (submodule {
          options = {
            type = mkOption {
              type = enum [
                "DOMAIN"
                "DOMAIN-SUFFIX"
                "DOMAIN-KEYWORD"
                "DOMAIN-WILDCARD"
                "DOMAIN-REGEX"
                "GEOSITE"
                "IP-CIDR"
                "IP-CIDR6"
                "IP-SUFFIX"
                "IP-ASN"
                "GEOIP"
                "SRC-GEOIP"
                "SRC-IP-ASN"
                "SRC-IP-CIDR"
                "SRC-IP-SUFFIX"
                "DST-PORT"
                "SRC-PORT"
                "IN-PORT"
                "IN-TYPE"
                "IN-USER"
                "IN-NAME"
                "PROCESS-PATH"
                "PROCESS-PATH-REGEX"
                "PROCESS-NAME"
                "PROCESS-NAME-REGEX"
                "UID"
                "NETWORK"
                "DSCP"
                "RULE-SET"
                "AND"
                "OR"
                "NOT"
                "SUB-RULE"
                "MATCH"
              ];
            };
            rule = mkOption {
              type = nullOr str;
              default = null;
            };
            priority = mkOption {
              type = int;
              default = 50;
            };
          };
        })
      );
    };

    settings = {
      allow-lan = mkOption { type = bool; };
      bind-address = mkOption {
        type = str;
        default = "*";
      };
      lan-allowed-ips = mkOption {
        type = listOf str;
        default = [
          "0.0.0.0/0"
          "::/0"
        ];
      };
      lan-disallowed-ips = mkOption {
        type = listOf str;
        default = [ ];
      };

      authentication = mkOption {
        type = listOf str;
        default = [ ];
      };
      skip-auth-prefixes = mkOption {
        type = listOf str;
        default = [ ];
      };

      mode = mkOption {
        type = enum [
          "rule"
          "global"
          "direct"
        ];
      };
      log-level = mkOption {
        type = enum [
          "silent"
          "error"
          "warning"
          "info"
          "debug"
        ];
      };
      ipv6 = mkOption { type = bool; };

      keep-alive-interval = mkOption { type = int; };
      keep-alive-idle = mkOption {
        type = int;
        default = 15;
      };
      disable-keep-alive = mkOption {
        type = bool;
        default = false;
      };

      find-process-mode = mkOption {
        type = enum [
          "always"
          "strict"
          "off"
        ];
      };

      external-controller = mkOption { type = str; };
      external-controller-cors = mkOption {
        type = submodule {
          options = {
            allow-origins = mkOption {
              type = listOf str;
              default = [ "*" ];
            };
            allow-private-network = mkOption {
              type = bool;
              default = true;
            };
          };
        };
        default = {
          allow-origins = [ "*" ];
          allow-private-network = true;
        };
      };
      external-controller-unix = mkOption {
        type = nullOr str;
        default = null;
      };
      external-controller-pipe = mkOption {
        type = nullOr str;
        default = null;
      };
      external-controller-tls = mkOption {
        type = nullOr str;
        default = null;
      };
      secret = mkOption {
        type = nullOr str;
        default = "";
      };

      external-ui = mkOption {
        type = nullOr str;
        default = null;
      };
      external-ui-name = mkOption {
        type = nullOr str;
        default = null;
      };
      external-ui-url = mkOption {
        type = nullOr str;
        default = null;
      };

      profile = mkOption {
        type = submodule {
          options = {
            store-selected = mkOption { type = bool; };
            store-fake-ip = mkOption { type = bool; };
          };
        };
      };

      unified-delay = mkOption { type = bool; };
      tcp-concurrent = mkOption { type = bool; };

      tls = mkOption {
        type = nullOr (submodule {
          options = {
            certificate = mkOption {
              type = str;
            };
            private-key = mkOption {
              type = str;
            };
            ech-key = mkOption {
              type = nullOr str;
            };
          };
        });
        default = null;
      };

      global-client-fingerprint = mkOption {
        type = nullOr (enum [
          "chrome"
          "firefox"
          "safari"
          "iOS"
          "android"
          "edge"
          "360"
          "qq"
          "random"
        ]);
      };

      geodata-mode = mkOption { type = bool; };
      geodata-loader = mkOption {
        type = enum [
          "standard"
          "memconservative"
        ];
        default = "memconservative";
      };
      geo-auto-update = mkOption {
        type = bool;
        default = false;
      };
      geo-update-interval = mkOption {
        type = int;
        default = 24;
      };

      geox-url = mkOption {
        type = submodule {
          options = {
            geoip = mkOption { type = str; };
            geosite = mkOption { type = str; };
            mmdb = mkOption { type = str; };
            asn = mkOption { type = str; };
          };
        };
      };

      global-ua = mkOption {
        type = str;
        default = "clash.meta";
      };
      etag-support = mkOption {
        type = bool;
        default = true;
      };
      mixed-port = mkOption { type = int; };

      sniffer = mkOption {
        type = nullOr (submodule {
          options = {
            enable = mkOption { type = bool; };
            sniff = mkOption { type = attrs; };
          };
        });
      };

      tun = mkOption {
        type = nullOr (submodule {
          options = {
            enable = mkOption {
              type = bool;
              default = cfg.tunMode;
            };
            stack = mkOption { type = str; };
            dns-hijack = mkOption { type = listOf str; };
            auto-route = mkOption { type = bool; };
            auto-detect-interface = mkOption { type = bool; };
          };
        });
      };

      dns = mkOption {
        type = nullOr (submodule {
          options = {
            enable = mkOption {
              type = bool;
              default = cfg.settings.tun.enable;
            };
            listen = mkOption { type = str; };
            ipv6 = mkOption { type = bool; };
            enhanced-mode = mkOption {
              type = enum [
                "redir-host"
                "fake-ip"
              ];
            };
            fake-ip-range = mkOption { type = str; };
            fake-ip-filter = mkOption { type = listOf str; };
            default-nameserver = mkOption { type = listOf str; };
            nameserver = mkOption { type = listOf str; };
            proxy-server-nameserver = mkOption { type = listOf str; };
            nameserver-policy = mkOption { type = attrs; };
          };
        });
      };

      ntp = mkOption {
        type = nullOr (submodule {
          options = {
            enable = mkOption { type = bool; };
            write-to-system = mkOption { type = bool; };
            server = mkOption { type = str; };
            port = mkOption { type = int; };
            interval = mkOption { type = int; };
          };
        });
      };
    };
  };

}
