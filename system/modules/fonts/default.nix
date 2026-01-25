{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  config = lib.mkIf config.hasDesktopEnvironment {
    fonts.packages = with pkgs; [
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
  };
}
