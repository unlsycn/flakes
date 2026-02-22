{
  config,
  user,
  pkgs,
  ...
}:
{
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      keepTerminfo = true;
      execWheelOnly = true;
    };
    doas = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };

  systemd.services.promote-ssh-key-to-user-age = {
    description = "Convert host SSH key to age key for user Home Manager";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script =
      let
        userAgeKeyFile = config.home-manager.users.${user}.sops.age.keyFile;
      in
      ''
        mkdir -p "$(dirname "${userAgeKeyFile}")"
        if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
          ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > "${userAgeKeyFile}"
          
          chown ${user}:users "${userAgeKeyFile}"
          chmod 600 "${userAgeKeyFile}"
          
          echo "Host SSH key has been promoted to ${userAgeKeyFile}"
        else
          echo "Host SSH key not found, skipping conversion."
          exit 1
        fi
      '';
  };
}
