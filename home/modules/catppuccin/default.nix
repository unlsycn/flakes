{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    flavor = "mocha";
    waybar.mode = "createLink";
    vscode.profiles.default.flavor = "macchiato";
    fcitx5.enable = false;
  };
}
