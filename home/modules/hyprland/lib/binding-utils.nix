{ lib, ... }:
with lib;
with builtins;
let
  toLua = generators.toLua { };
  raw = generators.mkLuaInline;

  normalizeKey =
    key:
    {
      Super = "SUPER";
      Alt = "ALT";
      Control = "CTRL";
      Ctrl = "CTRL";
      Shift = "SHIFT";
    }
    .${key} or key;

  keyCombo =
    modifier: key:
    concatStringsSep " + " (
      map normalizeKey ((optionals (modifier != "") (splitString " " modifier)) ++ [ key ])
    );

  workspaceSelector = workspace: if isInt workspace then toString workspace else workspace;

  isWrappedAction = action: isAttrs action && action ? action && action ? options;
  isManyAction = action: isAttrs action && action ? actions;
in
{
  config.wayland.windowManager.hyprland.lib.bindingUtils = rec {
    mainModifier = "Super";
    usualModifier = "Alt";

    dsp = rec {
      exec = command: raw "hl.dsp.exec_cmd(${toLua command})";
      focus = direction: raw "hl.dsp.focus({ direction = ${toLua direction} })";
      layout = message: raw "hl.dsp.layout(${toLua message})";
      unlessLayout =
        layouts: dispatcher:
        raw ''
          function()
            local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
            if ws == nil then return end

            local disabled = (${toLua (genAttrs layouts (_: true))})[ws.tiled_layout]
            if disabled then return end

            hl.dispatch(${dispatcher.expr})
          end
        '';
      layoutFor =
        messages:
        raw ''
          function()
            local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
            if ws == nil then return end

            local message = (${toLua messages})[ws.tiled_layout]
            if message == nil then return end

            hl.dispatch(hl.dsp.layout(message))
          end
        '';
      toggleLayout =
        defaultLayout: alternateLayout:
        raw ''
          function()
            local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
            if ws == nil then return end

            local layout = ${toLua defaultLayout}
            if ws.tiled_layout == ${toLua defaultLayout} then
              layout = ${toLua alternateLayout}
            end

            hl.workspace_rule({
              workspace = ws.name,
              layout = layout,
            })
          end
        '';
      submap = name: raw "hl.dsp.submap(${toLua name})";

      window = {
        close = raw "hl.dsp.window.close()";
        toggleFloating = raw "hl.dsp.window.float({ action = \"toggle\" })";
        maximize = raw "hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\" })";
        fullscreen = raw "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })";
        move = direction: raw "hl.dsp.window.move({ direction = ${toLua direction} })";
        moveToWorkspace =
          workspace: raw "hl.dsp.window.move({ workspace = ${toLua (workspaceSelector workspace)} })";
        drag = raw "hl.dsp.window.drag()";
        resize = raw "hl.dsp.window.resize()";
      };

      workspace = {
        focus = workspace: raw "hl.dsp.focus({ workspace = ${toLua (workspaceSelector workspace)} })";
        toggleSpecial = workspace: raw "hl.dsp.workspace.toggle_special(${toLua workspace})";
      };
    };

    opts = options: action: {
      inherit action options;
    };
    many = actions: { inherit actions; };
    doubleTap =
      delayMs: dispatcher:
      raw ''
        (function()
          local armed = false

          return function()
            if armed then
              armed = false
              hl.dispatch(${dispatcher.expr})
              return
            end

            armed = true

            hl.timer(function()
              armed = false
            end, {
              timeout = ${toString delayMs},
              type = "oneshot",
            })
          end
        end)()
      '';

    bind = modifier: key: dispatcher: options: {
      _args = [
        (keyCombo modifier key)
        dispatcher
      ]
      ++ optional (options != { }) options;
    };

    compile =
      modifier: keymap:
      let
        compileAction =
          key: action:
          if isManyAction action then
            concatMap (compileAction key) action.actions
          else
            let
              resolved =
                if isWrappedAction action then
                  action
                else
                  {
                    inherit action;
                    options = { };
                  };
            in
            [ (bind modifier key resolved.action resolved.options) ];
      in
      keymap |> mapAttrsToList compileAction |> flatten;

    mapActions = action: mapAttrs (_: action);

    main = compile mainModifier;
    mainShiftModifier = "${mainModifier} Shift";
    mainShift = compile mainShiftModifier;
    alt = compile usualModifier;
    altShift = compile "${usualModifier} Shift";
    ctrlAlt = compile "Control Alt";
    none = compile "";
  };
}
