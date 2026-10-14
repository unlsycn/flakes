{ config, lib, ... }:
with lib;
let
  cfg = config.services.cliproxyapi;

  sections =
    let
      apiKey = name: { api-key._secret = config.sops.secrets."cliproxyapi-${name}-api-key".path; };
    in
    {
      claude-api-key = {
        baseUrlPath = null;
        disable.excluded-models = [ "*" ];
        render = name: _: apiKey name;
      };

      codex-api-key = {
        baseUrlPath = "v1";
        disable.excluded-models = [ "*" ];
        render = name: _: apiKey name;
      };

      openai-compatibility = {
        baseUrlPath = "v1";
        disable.disabled = true;
        render = name: provider: {
          inherit name;
          inherit (provider) support-prompt-cache-key;
          headers = {
            "User-Agent" = "$User-Agent";
            Originator = "$originator";
            X-Codex-Window-Id = "$x-codex-window-id";
            X-Codex-Turn-Metadata = "$x-codex-turn-metadata";
            X-Codex-Installation-Id = "$x-codex-installation-id";
          };
          api-key-entries = [ (apiKey name) ];
        };
      };
    };
in
{
  imports = [
    ./options.nix
    ./providers.nix
  ];

  config = mkIf cfg.enable {
    services.cliproxyapi.settings = mkMerge [
      {
        host = "127.0.0.1";
        port = 8317;
        api-keys = [
          {
            _secret = config.sops.secrets.cliproxyapi-client-key.path;
          }
        ];
        remote-management = {
          allow-remote = false;
          secret-key = "";
          disable-control-panel = true;
        };
        routing.session-affinity = true;
        passthrough-headers = true;
        codex = {
          optimize-multi-agent-v2 = true;
          stream-bootstrap-buffering = true;
        };
      }

      (
        sections
        |> mapAttrs (
          sectionName: section:
          cfg.providers.${sectionName}
          |> mapAttrsToList (
            name: provider:
            {
              inherit (provider) priority;
              models =
                provider.models
                |> mapAttrsToList (
                  id: model:
                  removeAttrs model [ "upstream" ]
                  // {
                    name = model.upstream;
                  }
                  // optionalAttrs (model.upstream != id) {
                    alias = id;
                  }
                );
              base-url._secret =
                if section.baseUrlPath == null then
                  config.sops.secrets."cliproxyapi-${name}-base-url".path
                else
                  config.sops.templates."cliproxyapi-${name}-base-url-${section.baseUrlPath}".path;
            }
            // section.render name provider
            // optionalAttrs (!provider.enable) section.disable
          )
        )
      )
    ];

    sops.secrets = mkMerge [
      {
        cliproxyapi-client-key = {
          sopsFile = ./secrets.yaml;
          key = "client-key";
          restartUnits = [ "cliproxyapi.service" ];
        };
      }

      (
        cfg.providers
        |> attrValues
        |> concatMap attrNames
        |> unique
        |> concatMap (name: [
          "${name}-api-key"
          "${name}-base-url"
        ])
        |> map (
          key:
          nameValuePair "cliproxyapi-${key}" {
            sopsFile = ./secrets.yaml;
            inherit key;
            restartUnits = [ "cliproxyapi.service" ];
          }
        )
        |> listToAttrs
      )
    ];

    sops.templates =
      sections
      |> filterAttrs (_: section: section.baseUrlPath != null)
      |> mapAttrsToList (
        sectionName: section:
        cfg.providers.${sectionName}
        |> attrNames
        |> map (
          name:
          nameValuePair "cliproxyapi-${name}-base-url-${section.baseUrlPath}" {
            content = "${config.sops.placeholder."cliproxyapi-${name}-base-url"}/${section.baseUrlPath}";
          }
        )
      )
      |> concatLists
      |> listToAttrs;

    assertions = [
      {
        assertion = cfg.providers |> attrValues |> any (section: section != { });
        message = "services.cliproxyapi.providers must contain at least one upstream provider.";
      }
    ];

    mesh.services.llm = {
      internalPort = cfg.settings.port;
      exposure = {
        nebula = true;
        tailnet = true;
      };
      extraConfig = ''
        client_max_body_size 128m;
        proxy_buffering off;
        proxy_read_timeout 1800s;
        proxy_send_timeout 60s;
      '';
    };
  };
}
