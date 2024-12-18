{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.services.evremap.enable {
    services.evremap.settings.remap = [
      {
        input = [ "KEY_CAPSLOCK" ];
        output = [ "KEY_LEFTCTRL" ];
      }
    ];
  };
}
