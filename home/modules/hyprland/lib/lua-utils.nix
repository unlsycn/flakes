{ lib, ... }:
with lib;
let
  toLua = generators.toLua { };
  raw = generators.mkLuaInline;
in
{
  config.wayland.windowManager.hyprland.lib.luaUtils = rec {
    inherit raw toLua;

    call = args: { _args = args; };

    execCmd = command: raw "hl.dsp.exec_cmd(${toLua command})";
    submap = name: raw "hl.dsp.submap(${toLua name})";
    layout = message: raw "hl.dsp.layout(${toLua message})";

    startupHook = commands: ''
      hl.on("hyprland.start", function()
      ${concatMapStrings (command: "  hl.exec_cmd(${toLua command})\n") commands}end)
    '';
  };
}
