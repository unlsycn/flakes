{ lib, ... }:
with lib;
with builtins;
rec {
  mainModifier = "Super";
  usualModifier = "Alt";
  bindKeys =
    modifier: keybinds:
    keybinds |> mapAttrsToList (key: dispatcher: "${modifier}, ${key}, ${dispatcher}");
  mainBind = bindKeys mainModifier;
  mainShiftModifier = "${mainModifier} Shift";
  mainShiftBind = bindKeys mainShiftModifier;
  usualBind = bindKeys usualModifier;

  bindWithDispatcher =
    bindFunc: dispatcher: keybinds:
    keybinds |> mapAttrs (key: param: "${dispatcher}, " + param) |> bindFunc;
  bindWithDispatcher' =
    dispatcher: bindAttrs:
    bindAttrs
    |> mapAttrsToList (modifier: keybinds: bindWithDispatcher (bindKeys modifier) dispatcher keybinds)
    |> flatten;
}
