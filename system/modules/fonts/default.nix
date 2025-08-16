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
      jetbrains-mono
      roboto
      lxgw-wenkai

      maple-mono.NF-unhinted
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono

      openmoji-color
    ];
  };
}
