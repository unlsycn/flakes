{ lib, ... }:
with lib;
with builtins;
let
  toLua = generators.toLua { };
  raw = generators.mkLuaInline;

  workspaceSelector = workspace: if isInt workspace then toString workspace else workspace;

  mainModifier = "Super";
  usualModifier = "Alt";

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
      (concatStringsSep " + " (
        map (
          part:
          {
            Super = "SUPER";
            Alt = "ALT";
            Control = "CTRL";
            Ctrl = "CTRL";
            Shift = "SHIFT";
          }
          .${part} or part
        ) ((optionals (modifier != "") (splitString " " modifier)) ++ [ key ])
      ))
      dispatcher
    ]
    ++ optional (options != { }) options;
  };

  compile =
    modifier: keymap:
    let
      compileAction =
        key: action:
        if isAttrs action && action ? actions then
          concatMap (compileAction key) action.actions
        else
          let
            resolved =
              if isAttrs action && action ? action && action ? options then
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
in
{
  config.wayland.windowManager.hyprland.lib.bindingUtils = {
    inherit
      bind
      compile
      doubleTap
      many
      mapActions
      opts
      ;

    dsp = {
      exec = command: raw "hl.dsp.exec_cmd(${toLua command})";
      focus = direction: raw "hl.dsp.focus({ direction = ${toLua direction} })";
      layoutFor =
        actions:
        raw ''
          function()
            local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
            if ws == nil then return end

            local function run(action)
              if type(action) == "function" then
                action()
              else
                hl.dispatch(action)
              end
            end

            ${
              actions
              |> mapAttrsToList (
                layout: action: ''
                  if ws.tiled_layout == ${toLua layout} then
                    run(${
                      if isString action then
                        "hl.dsp.layout(${toLua action})"
                      else if isAttrs action && action ? expr then
                        action.expr
                      else
                        throw "layoutFor values must be layout message strings or Lua actions"
                    })
                    return
                  end
                ''
              )
              |> concatStringsSep "\n"
            }
          end
        '';
      smartColumnToggle = raw ''
        function()
          local win = hl.get_active_window()
          local layout = win ~= nil and win.layout or nil
          local column_windows = layout ~= nil and layout.column ~= nil and layout.column.windows or nil
          local column_window_count = 0

          if column_windows ~= nil then
            for _, _ in pairs(column_windows) do
              column_window_count = column_window_count + 1
            end
          end

          local message = column_window_count > 1 and "promote" or "consume_or_expel prev"
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
        moveOrSwapScrollingColumn =
          direction:
          raw ''
            function()
              local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
              if ws ~= nil and ws.tiled_layout == "scrolling" then
                hl.dispatch(hl.dsp.layout(${toLua "swapcol ${direction}"}))
                return
              end

              hl.dispatch(hl.dsp.window.move({ direction = ${toLua direction} }))
            end
          '';
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

    main = compile mainModifier;
    mainShift = compile "${mainModifier} Shift";
    alt = compile usualModifier;
    altShift = compile "${usualModifier} Shift";
    ctrlAlt = compile "Control Alt";
    none = compile "";
  };
}
