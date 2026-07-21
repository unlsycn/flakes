{
  findutils,
  hyprland,
  jq,
  writeShellApplication,
  xdg-user-dirs,
  ...
}:
writeShellApplication {
  name = "switch-wallpaper";
  runtimeInputs = [
    findutils
    hyprland
    jq
    xdg-user-dirs
  ];
  text = ''
    wallpaperDirectory="''${1:-$(xdg-user-dir PICTURES)/wallpapers}"

    if [[ ! -d "$wallpaperDirectory" ]]; then
      exit 0
    fi

    mapfile -d "" wallpapers < <(find "$wallpaperDirectory" -maxdepth 1 -type f -print0)
    if (( ''${#wallpapers[@]} == 0 )); then
      exit 0
    fi

    wallpaper="''${wallpapers[RANDOM % ''${#wallpapers[@]}]}"

    while IFS= read -r monitor; do
      hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
    done < <(hyprctl -j monitors | jq -r '.[].name')
  '';
}
