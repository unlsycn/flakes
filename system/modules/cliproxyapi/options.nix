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

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Take this provider out of routing without deleting its configuration or
          secrets. Both spellings of CPA's own disable mechanism are emitted per
          section: `codex-api-key` entries get `excluded-models: ["*"]`, which
          empties the credential's model list so it is never a candidate (the
          same thing the management panel's disable button writes), and
          `openai-compatibility` entries get `disabled: true`, which skips the
          provider entirely. Flip back to `true` to re-enter the pool.
        '';
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
