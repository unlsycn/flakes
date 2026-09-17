{ lib, pkgs, ... }:
with lib;
let
  yamlType = (pkgs.formats.yaml { }).type;

  providerType = types.submodule {
    options = {
      models = mkOption {
        type = types.listOf (
          types.submodule {
            freeformType = yamlType;
            options.name = mkOption { type = types.str; };
          }
        );
      };

      priority = mkOption {
        type = types.int;
        default = 50;
      };

      support-prompt-cache-key = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
in
{
  options.services.cliproxyapi.providers = mkOption {
    type = types.submodule {
      options = {
        codex-api-key = mkOption {
          type = types.attrsOf providerType;
          default = { };
        };

        openai-compatibility = mkOption {
          type = types.attrsOf providerType;
          default = { };
        };
      };
    };
    default = { };
  };
}
