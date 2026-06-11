{ config, lib, ... }:
with lib;
with types;
let
  cfg = config.wayland.windowManager.hyprland;

  rulePrimitive = nullOr (oneOf [
    bool
    int
    float
    str
  ]);
  ruleValue = oneOf [
    rulePrimitive
    (attrsOf rulePrimitive)
  ];
  ruleModule = attrsOf ruleValue;

  generateWindowRule = name: rule: { name = rule.name or name; } // removeAttrs rule [ "name" ];
in
{
  options.wayland.windowManager.hyprland.windowRules = mkOption {
    type = attrsOf ruleModule;
    default = { };
    description = "Named window rules for Hyprland";
    example = literalExpression ''
      {
        vscode-opacity = {
          match.class = "code";
          opacity = "0.95";
        };
      }
    '';
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.window_rule = (
      mapAttrsToList generateWindowRule cfg.windowRules
    );
  };
}
