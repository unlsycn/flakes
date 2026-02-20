{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./sound.nix
    ./hardware.nix
  ];

  homeManagerProfiles = [
    "intimate"
  ];
  hasDesktopEnvironment = true;

  environment.persistence."/persist".enable = true;

  # mount onedrive as a separate dataset
  home-manager.users.${user}.programs.onedrive.persist = false;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    hashedPassword = "$6$zJg0P1UadaogMxN5$SifgGzUNYaK9kACNluny0j17LnFFfW4s.pjaCCPHJnQ.F55KFoEwoXJelhI7wughlksF0zNR.xwRQgpjR7X/0.";
    shell = pkgs.zsh;
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    evremap = {
      enable = true;
      settings.device_name = "AT Translated Set 2 keyboard";
    };
    zfs.enable = true;
  };

  mesh = {
    enable = true;
    id = 72;
  };

  networking.hostId = "7715be29";

  system.stateVersion = "25.05"; # Dont touch it
}
