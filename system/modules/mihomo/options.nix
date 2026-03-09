{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with types;
let
  cfg = config.services.mihomo;
  yamlType = (pkgs.formats.yaml { }).type;
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
    _defaultProxies = mkOption {
      type = listOf str;
      default = [
        "节点选择"
        "自动选择"
        "DIRECT"
        "REJECT"
      ]
      ++ (attrNames cfg.regions);
      internal = true;
      readOnly = true;
    };
    routes = mkOption {
      type = attrsOf (submodule {
        options = {
          rules = mkOption {
            type = listOf (submodule {
              options = {
                type = mkOption {
                  type = str;
                };
                rule = mkOption {
                  type = nullOr str;
                  default = null;
                };
                priority = mkOption {
                  type = int;
                  default = 50;
                };
                params = mkOption {
                  type = listOf str;
                  default = [ ];
                  description = "Additional parameters";
                };
              };
            });
          };
          proxies = mkOption {
            type = listOf str;
            default = cfg._defaultProxies;
          };
          default = mkOption {
            type = nullOr str;
            default = "节点选择";
          };
        };
      });
    };

    settings = mkOption {
      type = submodule {
        freeformType = yamlType;
        options = {
          tun = mkOption {
            type = nullOr (submodule {
              freeformType = yamlType;
              options = {
                enable = mkOption {
                  type = bool;
                  readOnly = true;
                  default = cfg.tunMode;
                };
                route-exclude-address = mkOption {
                  type = listOf str;
                  default = [ ];
                };
              };
            });
            default = null;
          };

          dns = mkOption {
            type = nullOr (submodule {
              freeformType = yamlType;
              options = {
                enable = mkOption {
                  type = bool;
                  default = cfg.settings.tun.enable;
                };
                fake-ip-filter = mkOption {
                  type = listOf str;
                  default = [ ];
                };
              };
            });
          };
        };
      };
    };
  };

}
