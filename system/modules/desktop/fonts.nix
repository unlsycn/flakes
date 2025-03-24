{ pkgs, ... }:
{
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
}
