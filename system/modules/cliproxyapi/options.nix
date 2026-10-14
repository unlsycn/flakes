{ lib, pkgs, ... }:
with lib;
{
  options.services.cliproxyapi.providers =
    let
      provider = {
        options = {
          models = mkOption {
            type = types.attrsOf (
              types.submodule (
                { name, ... }:
                {
                  freeformType = (pkgs.formats.yaml { }).type;
                  options.upstream = mkOption {
                    type = types.str;
                    default = name;
                    description = ''
                      Model name sent upstream. The attribute name is the model clients
                      request; it is emitted as `alias` when the two differ.
                    '';
                  };
                }
              )
            );
          };

          priority = mkOption {
            type = types.int;
            default = 50;
          };

          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this provider takes part in routing; disabling keeps its config
              and secrets but emits the section's own disable flag.
            '';
          };
        };
      };
    in
    mkOption {
      type = types.submodule {
        options = {
          claude-api-key = mkOption {
            type = types.attrsOf (types.submodule provider);
            default = { };
          };

          codex-api-key = mkOption {
            type = types.attrsOf (types.submodule provider);
            default = { };
          };

          openai-compatibility = mkOption {
            type = types.attrsOf (
              types.submodule [
                provider
                {
                  options.support-prompt-cache-key = mkOption {
                    type = types.bool;
                    default = false;
                  };
                }
              ]
            );
            default = { };
          };
        };
      };
      default = { };
    };
}
