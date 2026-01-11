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
        "香港".filter = ''(?i)🇭🇰|港|hk|hong kong'';
        "台湾".filter = ''(?i)🇹🇼|台|tw|taiwan'';
        "日本".filter = ''(?i)🇯🇵|日|jp|japan'';
        "美国".filter = ''(?i)🇺🇸|美|us|united states'';
        "新加坡".filter = ''(?i)🇸🇬|新|sg|singapore'';
        "其他地区".filter =
          ''(?i)^(?!.*(?:🇭🇰|🇹🇼|🇯🇵|🇺🇸|🇸🇬|港|hk|hongkong|台|tw|taiwan|日|jp|japan|新|sg|singapore|美|us|united states)).*'';
      };
      routes = {
        "Apple" = [
          {
            type = "GEOSITE";
            rule = "apple";
          }
          {
            type = "GEOSITE";
            rule = "apple-cn";
          }
        ];
        "ehentai" = [
          {
            type = "GEOSITE";
            rule = "ehentai";
          }
        ];
        "Github" = [
          {
            type = "GEOSITE";
            rule = "github";
          }
        ];
        "Twitter" = [
          {
            type = "GEOSITE";
            rule = "twitter";
          }
          {
            type = "GEOIP";
            rule = "twitter";
          }
        ];
        "YouTube" = [
          {
            type = "GEOSITE";
            rule = "youtube";
          }
        ];
        "Google" = [
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
        "Telegram" = [
          {
            type = "GEOSITE";
            rule = "telegram";
          }
          {
            type = "GEOIP";
            rule = "telegram";
          }
        ];
        "NETFLIX" = [
          {
            type = "GEOSITE";
            rule = "netflix";
          }
          {
            type = "GEOIP";
            rule = "netflix";
          }
        ];
        "巴哈姆特" = [
          {
            type = "GEOSITE";
            rule = "bahamut";
          }
        ];
        "Spotify" = [
          {
            type = "GEOSITE";
            rule = "spotify";
          }
        ];
        "Pixiv" = [
          {
            type = "GEOSITE";
            rule = "pixiv";
          }
        ];
        "Steam" = [
          {
            type = "GEOSITE";
            rule = "steam";
          }
        ];
        "OneDrive" = [
          {
            type = "GEOSITE";
            rule = "onedrive";
          }
        ];
        "LLM Providers" = [
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
        "国内" = [
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
        "国外" = [
          {
            type = "GEOSITE";
            rule = "geolocation-!cn";
            priority = 10;
          }
        ];
        "非 Web 协议" = [
          {
            type = "NOT";
            rule = "((DST-PORT,80/443))";
            priority = 20;
          }
        ];
        "其他" = [
          {
            type = "MATCH";
            priority = 0;
          }
        ];
        "广告拦截" = [
          {
            type = "AND";
            rule = "((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white))))";
            priority = 100;
          }
        ];
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
        proxyGroups =
          let
            proxies = [
              "DIRECT"
              "REJECT"
            ]
            ++ (attrNames cfg.regions);
          in
          [
            {
              name = "节点选择";
              type = "select";
              proxies = [
                "自动选择"
              ]
              ++ proxies;
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
            [ "DNS" ] ++ (attrNames cfg.routes)
            |> map (name: {
              name = name;
              type = "select";
              proxies =
                if name == "国内" then
                  # default to DIRECT
                  proxies
                else
                  [
                    "节点选择"
                    "自动选择"
                  ]
                  ++ proxies;
            })
          );
        rules =
          cfg.routes
          |> mapAttrsToList (
            name: rules:
            rules
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

    networking.firewall = {
      trustedInterfaces = [ "Meta" ];
      checkReversePath = "loose";
    };
  };
}
