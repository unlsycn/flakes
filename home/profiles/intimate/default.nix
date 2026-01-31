{
  config,
  lib,
  ...
}:
with lib;
{
  options.profile.intimate = {
    enable = mkEnableOption "home-manager profile for trusted environment";
  };

  config = mkIf config.profile.intimate.enable {
    programs = {
      onedrive.enable = true;
      # beets.enable = true;
    };

    services = {
      gpg-agent.enable = true;
    };

    sops.control = {
      deploySshSecrets = true;
      deployPrivateFiles = true;
    };
  };
}
