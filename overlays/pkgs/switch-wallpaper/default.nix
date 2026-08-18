{
  coreutils,
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
    coreutils
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

    deadline=$((SECONDS + 10))
    while :; do
      failed=0
      while IFS= read -r monitor; do
        response=$(hyprctl hyprpaper wallpaper "$monitor,$wallpaper" 2>&1) || failed=1
        [[ "$response" == *rror* || "$response" == *ouldn* ]] && failed=1
      done < <(hyprctl -j monitors | jq -r '.[].name')

      if (( failed == 0 )); then
        exit 0
      fi
      if (( SECONDS >= deadline )); then
        echo "hyprpaper did not become reachable: $response" >&2
        exit 1
      fi
      sleep 0.5
    done
  '';
}
