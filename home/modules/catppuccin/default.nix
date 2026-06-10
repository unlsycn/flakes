{ config, inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    autoEnable = true;
    flavor = "mocha";
    waybar.mode = "createLink";
    vscode.profiles.default = {
      flavor = "macchiato";
      icons.flavor = config.catppuccin.vscode.profiles.default.flavor;
    };
    antigravity.profiles.default = {
      flavor = config.catppuccin.vscode.profiles.default.flavor;
      icons.flavor = config.catppuccin.antigravity.profiles.default.flavor;
    };
    fcitx5.enable = false;
  };
}
