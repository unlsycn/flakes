{
  config,
  lib,
  ...
}:
with lib;
{
  options.profile.stateless = {
    enable = mkEnableOption "home-manager profile for stateless environment";
  };

  config = mkIf config.profile.stateless.enable {
    home.persistence."/persist".enable = true;
  };
}
