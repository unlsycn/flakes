{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.deskflow;

  mkRange = r: "(${toString r.start},${toString r.end})";

  mkLinkTarget =
    target: "${target.screen}${if target ? start && target ? end then mkRange target else ""}";

  mkLinkLine =
    dir: targets:
    targets
    |> concatMapStringsSep "\n" (
      t:
      let
        srcRange =
          if t ? srcStart && t ? srcEnd then "(${toString t.srcStart},${toString t.srcEnd})" else "";
        targetStr = mkLinkTarget t;
      in
      "\t\t${dir}${srcRange} = ${targetStr}"
    );

  mkLinks =
    host: directions:
    directions
    |> mapAttrsToList (
      dir: targets:
      targets |> toList |> map (t: if isString t then { screen = t; } else t) |> mkLinkLine dir
    )
    |> concatStringsSep "\n";

in
{
  options.services.deskflow = {
    enable = mkEnableOption "Deskflow service";

    package = mkOption {
      type = types.package;
      default = pkgs.deskflow;
      description = "The Deskflow package to use.";
    };

    server = {
      enable = mkEnableOption "Deskflow server";

      config = mkOption {
        description = "Deskflow server text configuration.";
        type = types.submodule {
          options = {
            screens = mkOption {
              type = types.attrsOf (types.attrsOf types.anything);
              default = { };
              description = "Screen definitions (hostnames). Options for each screen can be specified as attributes.";
            };

            aliases = mkOption {
              type = types.attrsOf (types.listOf types.str);
              default = { };
              description = "Aliases for screens.";
            };

            links = mkOption {
              type = types.attrsOf (
                types.attrsOf (types.either types.str (types.listOf (types.attrsOf types.anything)))
              );
              default = { };
              description = "Link definitions defining the layout.";
            };

            options = mkOption {
              type = types.attrsOf types.anything;
              default = { };
              description = "Global options.";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."Deskflow/deskflow-server.conf".text = mkIf cfg.server.enable (
      let
        c = cfg.server.config;

        screensSection = ''
          section: screens
          ${
            c.screens
            |> mapAttrsToList (
              name: opts:
              "\t${name}:\n"
              + (opts |> mapAttrsToList (k: v: "\t\t${k} = ${toString v}") |> concatStringsSep "\n")
            )
            |> concatStringsSep "\n"
          }
          end
        '';

        aliasesSection = optionalString (c.aliases != { }) ''
          section: aliases
          ${
            c.aliases
            |> mapAttrsToList (
              name: aliasList: "\t${name}:\n" + (aliasList |> map (a: "\t\t${a}") |> concatStringsSep "\n")
            )
            |> concatStringsSep "\n"
          }
          end
        '';

        linksSection = optionalString (c.links != { }) ''
          section: links
          ${
            c.links
            |> mapAttrsToList (host: dirs: "\t${host}:\n" + (mkLinks host dirs))
            |> concatStringsSep "\n"
          }
          end
        '';

        optionsSection = optionalString (c.options != { }) ''
          section: options
          ${c.options |> mapAttrsToList (k: v: "\t${k} = ${toString v}") |> concatStringsSep "\n"}
          end
        '';
      in
      screensSection + aliasesSection + linksSection + optionsSection
    );

    systemd.user.services.deskflow-server = mkIf cfg.server.enable {
      Unit = {
        Description = "Deskflow Server";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/deskflow-core server";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
