{ config, lib, ... }:
with lib;
let
  cfg = config.services.cliproxyapi;
in
{
  imports = [
    ./options.nix
    ./providers.nix
  ];

  config = mkIf cfg.enable {
    services.cliproxyapi.settings = {
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
    };

    sops.secrets.cliproxyapi-client-key = {
      sopsFile = ./secrets.yaml;
      key = "client-key";
      restartUnits = [ "cliproxyapi.service" ];
    };

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
