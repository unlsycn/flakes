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
    targets.genericLinux.enable = true;

    sops.secrets = mkForce { };

    programs = {
      ssh.matchBlocks."*".identityFile = mkForce [ ];
      zellij.copyCommand = "";
    };
  };
}
