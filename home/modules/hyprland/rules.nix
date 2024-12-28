{ config, lib, ... }:
with lib;
with types;
let
  cfg = config.wayland.windowManager.hyprland;
  rulesType = attrsOf (coercedTo (either (listOf str) str) toList (listOf str));
  windowRuleModule = submodule {
    options = {
      class = mkOption {
        type = rulesType;
        default = { };
        example = ''
          {
            "wechat" = [ "noblur" "float" ];
          }
        '';
      };
      title = mkOption {
        type = rulesType;
        default = { };
        example = ''
          {
            "Visual Studio Code" = "opacity 0.95";
          }
        '';
      };
      initialClass = mkOption {
        type = rulesType;
        default = { };
        example = ''
          {
            wechat = [ "noblur" "float" ];
          }
        '';
      };
      initialTitle = mkOption {
        type = rulesType;
        default = { };
        example = ''
          {
            "^(Visual Studio Code)$" = "opacity 0.95";
          }
        '';
      };
      custom = mkOption {
        type = rulesType;
        default = { };
        example = ''
          {
            "class:(pinentry-)(.*) floating:1" = "pin";
          }
        '';
      };
    };
  };
in
{
  options.wayland.windowManager.hyprland.windowRules = mkOption {
    type = windowRuleModule;
    default = { };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.windowrulev2 =
      flatten (
        mapAttrsToList (
          field: ruleLines:
          mapAttrsToList (regex: rules: "${concatStringsSep ", " rules}, ${field}:${regex}") ruleLines
        ) (removeAttrs cfg.windowRules [ "custom" ])
      )
      ++ mapAttrsToList (
        fieldRegex: rules: "${concatStringsSep ", " rules}, ${fieldRegex}"
      ) cfg.windowRules.custom;
  };
}
