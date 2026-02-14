{ config, lib, ... }:
with lib;
with types;
let
  cfg = config.wayland.windowManager.hyprland;

  propModule = submodule {
    options = {
      type = mkOption {
        type = enum [
          "class"
          "title"
          "initial_class"
          "initial_title"
          "tag"
          "xwayland"
          "float"
          "fullscreen"
          "pin"
          "focus"
          "group"
          "modal"
          "fullscreen_state_client"
          "fullscreen_state_internal"
          "workspace"
          "content"
          "xdg_tag"
        ];
        description = "The type of match property";
      };
      value = mkOption {
        type = str;
        description = "The value to match against";
      };
    };
  };

  effectModule = submodule {
    options = {
      type = mkOption {
        type = str;
        description = "The effect type (e.g., border_size, opacity, float, etc.)";
      };
      value = mkOption {
        type = nullOr str;
        default = null;
        description = "The value for the effect (null if the effect is a boolean flag)";
      };
    };
  };

  ruleModule = submodule {
    options = {
      props = mkOption {
        type = listOf propModule;
        default = [ ];
        description = "List of match properties that must all be satisfied";
        example = literalExpression ''
          [
            { type = "class"; value = "my-window"; }
            { type = "float"; value = "1"; }
          ]
        '';
      };

      effects = mkOption {
        type = listOf effectModule;
        default = [ ];
        description = "List of effects to apply to matched windows";
        example = literalExpression ''
          [
            { type = "border_size"; value = "10"; }
            { type = "opacity"; value = "0.95"; }
            { type = "float"; value = null; }
          ]
        '';
      };
    };
  };

  generateWindowRule =
    name: rule:
    let
      propsStr = concatMapStringsSep "\n" (prop: "match:${prop.type} = ${prop.value}") rule.props;
      effectsStr = concatMapStringsSep "\n" (
        effect: if effect.value == null then effect.type else "${effect.type} = ${effect.value}"
      ) rule.effects;
    in
    ''
      windowrule {
        name = ${name}
        ${propsStr}

        ${effectsStr}
      }
    '';
in
{
  options.wayland.windowManager.hyprland.windowRules = mkOption {
    type = attrsOf ruleModule;
    default = { };
    description = "Named window rules for Hyprland";
    example = literalExpression ''
      {
        vscode-opacity = {
          props = [
            { type = "class"; value = "code"; }
          ];
          effects = [
            { type = "opacity"; value = "0.95"; }
          ];
        };
      }
    '';
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = concatStringsSep "\n" (
      mapAttrsToList generateWindowRule cfg.windowRules
    );
  };
}
