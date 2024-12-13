{ lib, ... }:
with lib;
with builtins;
rec {
  mainModifier = "Super";
  usualModifier = "Alt";
  bindKeys =
    modifier: keybinds: mapAttrsToList (name: value: "${modifier}, ${name}, ${value}") keybinds;
  mainBind = bindKeys mainModifier;
  mainShiftModifier = "${mainModifier} Shift";
  mainShiftBind = bindKeys mainShiftModifier;
  usualBind = bindKeys usualModifier;

  bindWithDispatcher =
    bindFunc: dispatcher: keybinds:
    bindFunc (mapAttrs (name: value: "${dispatcher}, " + value) keybinds);
}
