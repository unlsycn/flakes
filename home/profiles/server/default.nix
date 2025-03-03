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

    services.gpg-agent.enable = mkForce false;
    systemd.user.services.sops-nix.Install.WantedBy = mkForce [ ];
  };
}
