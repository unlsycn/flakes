{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  config = lib.mkIf config.hasDesktopEnvironment {
    fonts = {
      packages = with pkgs; [
        maple-mono.truetype
        maple-mono.NF-unhinted
        jetbrains-mono

        inter
        roboto
        merriweather

        lxgw-wenkai
        sarasa-gothic

        nerd-fonts.jetbrains-mono
        nerd-fonts.roboto-mono

        openmoji-color
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [
            "Inter"
            "Sarasa Mono SC"
            "Roboto"
          ];

          serif = [
            "Merriweather"
            "LXGW WenKai Mono"
          ];

          monospace = [
            "Maple Mono NF"
            "Sarasa Mono SC"
          ];
        };
      };
    };
  };
}
