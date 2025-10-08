{
  config,
  lib,
  ...
}:
with lib;
{
  options.profile.server = {
    enable = mkEnableOption "home-manager profile for servers, patched from CLI profile";
  };

  config = mkIf config.profile.server.enable {
    profile.cli.enable = mkForce true;
    targets.genericLinux.enable = true;

    sops.secrets = mkForce { };

    programs = {
      ssh.matchBlocks."*".identityFile = mkForce [ ];
      zellij.copyCommand = "";
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "impure-derivations"
      "pipe-operators"
    ];
  };
}
