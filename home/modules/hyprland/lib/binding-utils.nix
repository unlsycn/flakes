{ lib, ... }:
with lib;
with builtins;
rec {
  mainModifier = "Super";
  usualModifier = "Alt";
  bindKeys =
    modifier: keybinds: mapAttrsToList (key: dispatcher: "${modifier}, ${key}, ${dispatcher}") keybinds;
  mainBind = bindKeys mainModifier;
  mainShiftModifier = "${mainModifier} Shift";
  mainShiftBind = bindKeys mainShiftModifier;
  usualBind = bindKeys usualModifier;

  bindWithDispatcher =
    bindFunc: dispatcher: keybinds:
    bindFunc (mapAttrs (key: param: "${dispatcher}, " + param) keybinds);
}
