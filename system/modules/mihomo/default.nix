{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
with lib;
let
  cfg = config.services.mihomo;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    services.mihomo = {
      tunMode = mkDefault true;
      webui = pkgs.metacubexd;

      settings = {
        mode = "rule";
        ipv6 = false;
        log-level = "info";
        allow-lan = true;
        mixed-port = 1970;
        unified-delay = true;
        tcp-concurrent = true;
        external-controller = ":9090";
        geodata-mode = true;
        geox-url = {
          geoip = "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat";
          geosite = "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat";
          mmdb = "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb";
          asn = "https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb";
        };
        find-process-mode = "strict";
        keep-alive-interval = 1800;
        global-client-fingerprint = "random";
        profile = {
          store-selected = true;
          store-fake-ip = true;
        };
        ntp = {
          enable = true;
          write-to-system = false;
          server = "time.apple.com";
          port = 123;
          interval = 30;
        };
        sniffer = {
          enable = true;
          sniff = {
            HTTP = {
              ports = [
                80
                "8080-8880"
              ];
            };
            TLS = {
              ports = [
                443
                8443
              ];
            };
            QUIC = {
              ports = [
                443
                8443
              ];
            };
          };
        };
        tun = {
          stack = "system";
          dns-hijack = [
            "any:53"
            "tcp://any:53"
          ];
          auto-route = true;
          auto-detect-interface = true;
        };
        dns =
          let
            bootstrap-ip = [
              "223.5.5.5"
              "119.29.29.29"
            ];
            cn-doh = [
              "https://doh.pub/dns-query"
              "https://dns.alidns.com/dns-query"
            ];
          in
          {
            enable = true;
            listen = ":1053";
            ipv6 = false;
            enhanced-mode = "fake-ip";
            fake-ip-range = "28.0.0.1/8";
            fake-ip-filter = [
              "+.lan"
              "+.local"
            ];

            nameserver = cn-doh;
            default-nameserver = bootstrap-ip;
            proxy-server-nameserver = bootstrap-ip ++ cn-doh;

            fallback = [
              "tls://8.8.4.4#DNS"
              "tls://1.0.0.1#DNS"
            ];
            fallback-filter = {
              geoip = true;
              geoip-code = "CN";
              geosite = [ "gfw" ];
            };

            nameserver-policy = {
              "geosite:cn,private" = cn-doh;
            };
          };
      };

      proxyProviders = {
        "Haita".type = "http";
        "Longmao".type = "http";
        "Sakana".type = "http";
      };
      ruleProviders = {
        "anti-AD" = {
          type = "http";
          behavior = "domain";
          url = "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml";
        };
        anti-AD-white = {
          type = "http";
          behavior = "domain";
          url = "https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-for-clash.yaml";
        };
      };
      regions = {
        "香港".filter = ''(?i)🇭🇰|港|\bhk\b|hong kong'';
        "台湾".filter = ''(?i)🇹🇼|台|\btw\b|taiwan'';
        "日本".filter = ''(?i)🇯🇵|日|\bjp\b|japan'';
        "美国".filter = ''(?i)🇺🇸|美|\bus\b|united states'';
        "新加坡".filter = ''(?i)🇸🇬|新|\bsg\b|singapore'';
        "其他地区".filter =
          ''(?i)^(?!.*(?:🇭🇰|🇹🇼|🇯🇵|🇺🇸|🇸🇬|港|\bhk\b|hongkong|台|\btw\b|taiwan|日|\bjp\b|japan|新|\bsg\b|singapore|美|\bus\b|united states)).*'';
      };
      routes = {
        "Apple" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "apple";
            }
            {
              type = "GEOSITE";
              rule = "apple-cn";
            }
          ];
        };
        "DNS" = {
          rules = [ ];
        };
        "E-Hentai" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "ehentai";
            }
          ];
        };
        "Github" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "github";
            }
          ];
        };
        "Google" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "google";
            }
            {
              type = "GEOSITE";
              rule = "google-cn";
            }
            {
              type = "GEOIP";
              rule = "google";
            }
          ];
          proxies = cfg._defaultProxies ++ [ "LLM Providers" ];
          default = "LLM Providers";
        };
        "LLM Providers" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "openai";
            }
            {
              type = "GEOSITE";
              rule = "google-gemini";
              priority = 75;
            }
            {
              type = "GEOSITE";
              rule = "anthropic";
            }
          ];
          default = "美国";
        };
        "Netflix" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "netflix";
            }
            {
              type = "GEOIP";
              rule = "netflix";
            }
          ];
        };
        "OneDrive" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "onedrive";
            }
          ];
        };
        "Pixiv" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "pixiv";
            }
          ];
        };
        "Spotify" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "spotify";
            }
          ];
        };
        "Steam" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "steam";
            }
          ];
        };
        "Telegram" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "telegram";
            }
            {
              type = "GEOIP";
              rule = "telegram";
            }
          ];
        };
        "Twitter" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "twitter";
            }
            {
              type = "GEOIP";
              rule = "twitter";
            }
          ];
        };
        "YouTube" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "youtube";
            }
          ];
        };
        "其他" = {
          rules = [
            {
              type = "MATCH";
              priority = 0;
            }
          ];
        };
        "巴哈姆特" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "bahamut";
            }
          ];
        };
        "广告拦截" = {
          rules = [
            {
              type = "AND";
              rule = "((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white))))";
              priority = 100;
            }
          ];
          default = "REJECT";
        };
        "国内" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "CN";
            }
            {
              type = "GEOIP";
              rule = "CN";
            }
            {
              type = "GEOSITE";
              rule = "steam@cn";
              priority = 75;
            }
          ];
          default = "DIRECT";
        };
        "国外" = {
          rules = [
            {
              type = "GEOSITE";
              rule = "geolocation-!cn";
              priority = 10;
            }
          ];
        };
        "非 Web 协议" = {
          rules = [
            {
              type = "NOT";
              rule = "((DST-PORT,80/443))";
              priority = 20;
            }
          ];
          default = "DIRECT";
        };
      };
      configFile = config.sops.templates."mihomoConfig".path;
    };

    sops.secrets =
      cfg.proxyProviders
      |> mapAttrs' (
        name: _:
        nameValuePair ("proxyProvider_" + name) {
          sopsFile = ./proxy-providers.yaml;
          key = name;
        }
      );

    sops.templates."mihomoConfig".content =
      let
        porxyProviders =
          cfg.proxyProviders
          |> mapAttrs (
            name: value:
            value
            // {
              interval = 3600;
              health-check = {
                enable = true;
                url = "https://www.gstatic.com/generate_204";
                interval = 300;
              };
              path = "./proxy_provider/${name}.yaml";
              url = config.sops.placeholder."proxyProvider_${name}";
            }
          );
        ruleProviders =
          cfg.ruleProviders
          |> mapAttrs (
            name: value:
            value
            // {
              path = "./rule_provider/${name}.yaml";
            }
          );
        proxyGroups = [
          {
            name = "节点选择";
            type = "select";
            proxies = cfg._defaultProxies |> filter (x: x != "节点选择");
          }
          {
            name = "自动选择";
            type = "url-test";
            use = attrNames cfg.proxyProviders;
            exclude-filter = ''\b(?:[2-9](?:\.\d+)?|[1-9]\d+(?:\.\d+)?|1\.(?:0*[1-9]\d*|0+[1-9]))x\b'';
            tolerance = 2;
          }
        ]
        ++ (
          cfg.regions
          |> mapAttrsToList (
            name: value: {
              name = name;
              type = "select";
              use = attrNames cfg.proxyProviders;
              filter = value.filter;
            }
          )
        )
        ++ (
          cfg.routes
          |> mapAttrsToList (
            name: route:
            let
              proxies =
                if (route.default != null) && (elem route.default route.proxies) then
                  [ route.default ] ++ (route.proxies |> filter (x: x != route.default))
                else
                  throw "Route '${name}': default '${route.default}' not found in proxies list";
            in
            {
              name = name;
              type = "select";
              proxies = proxies;
            }
          )
        );
        rules =
          cfg.routes
          |> mapAttrsToList (
            name: route:
            route.rules
            |> map (rule: {
              priority = rule.priority;
              rule = "${rule.type},${optionalString (rule.rule != null) "${rule.rule},"}${name}";
            })
          )
          |> flatten
          |> sort (a: b: a.priority > b.priority)
          |> map (x: x.rule);
      in
      {
        proxy-providers = porxyProviders;
        rule-providers = ruleProviders;
        proxy-groups = proxyGroups;
        rules = rules;
      }
      // (cfg.settings |> filterAttrsRecursive (n: v: v != null))
      |> pkgs.lib.generators.toYAML { };

    networking = {
      firewall = {
        trustedInterfaces = [ "Meta" ];
        checkReversePath = "loose";
      };
      networkmanager.dispatcherScripts = [
        {
          source =
            let
              ssid = "Senesdanto";
              systemctl = "${pkgs.systemd}/bin/systemctl";
            in
            pkgs.writeShellScript "toggle-mihomo" ''
              INTERFACE=$1
              ACTION=$2
              if [ "$CONNECTION_ID" = "${ssid}" ]; then
                  case "$ACTION" in
                      up)
                          ${systemctl} stop mihomo.service
                          ;;
                      down)
                          ${systemctl} start mihomo.service
                          ;;
                  esac
              fi
            '';
        }
      ];
    };
  };
}
