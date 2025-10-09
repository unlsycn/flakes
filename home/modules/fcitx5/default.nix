{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.i18n.inputMethod;
in
with lib;
{
  config = mkIf (cfg.enable && cfg.type == "fcitx5") {
    i18n.inputMethod.fcitx5 = {
      addons = with pkgs; [ fcitx5-rime ];
      waylandFrontend = true;
    };

    xdg = {
      dataFile = {
        "fcitx5/rime/default.custom.yaml".text =
          { patch.schema_list = [ { schema = "flypy"; } ]; } |> generators.toYAML { };

        "fcitx5/themes".source = pkgs.fetchFromGitHub {
          owner = "thep0y";
          repo = "fcitx5-themes-candlelight";
          rev = "d4146d3d3f7a276a8daa2847c3e5c08de20485da";
          sha256 = "sha256-/IdN69izB30rl1gswsXivYtpAeCUdahP7oy06XJXo0I=";
        };
      };
      configFile = {
        "fcitx5/conf/classicui.conf".text =
          {
            "Vertical Candidate List" = "True";
            PerScreenDPI = "True";
            Theme = "summer";
          }
          |> generators.toKeyValue { };
      };
    };

    persist."/persist".users.${user}.directories = [ ".config/fcitx5" ];
  };
}
