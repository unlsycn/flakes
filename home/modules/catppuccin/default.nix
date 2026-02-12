{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    flavor = "mocha";
    waybar.mode = "createLink";
    fcitx5.enable = false;
  };
}
