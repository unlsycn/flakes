{ config, inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    flavor = "mocha";
    waybar.mode = "createLink";
    vscode.profiles.default = {
      flavor = "macchiato";
      icons.flavor = config.catppuccin.vscode.profiles.default.flavor;
    };
    fcitx5.enable = false;
  };
}
