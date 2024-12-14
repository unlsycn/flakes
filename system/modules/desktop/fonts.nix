{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    jetbrains-mono
    roboto
    lxgw-wenkai

    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono

    openmoji-color
  ];
}
