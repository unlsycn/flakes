{
  pamixer,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "volume-control";
  runtimeInputs = [ pamixer ];
  text = ''
    case "''${1:---get}" in
      --get)
        pamixer --get-volume-human
        ;;
      --inc)
        if [[ "$(pamixer --get-mute)" == "true" ]]; then
          pamixer --toggle-mute
        else
          pamixer --increase 5 --allow-boost --set-limit 150
        fi
        ;;
      --dec)
        if [[ "$(pamixer --get-mute)" == "true" ]]; then
          pamixer --toggle-mute
        else
          pamixer --decrease 5
        fi
        ;;
      --toggle)
        pamixer --toggle-mute
        ;;
      --mic-toggle)
        pamixer --default-source --toggle-mute
        ;;
      --mic-inc)
        if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
          pamixer --default-source --toggle-mute
        else
          pamixer --default-source --increase 5
        fi
        ;;
      --mic-dec)
        if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
          pamixer --default-source --toggle-mute
        else
          pamixer --default-source --decrease 5
        fi
        ;;
      *)
        echo "Usage: volume-control [--get|--inc|--dec|--toggle|--mic-toggle|--mic-inc|--mic-dec]" >&2
        exit 2
        ;;
    esac
  '';
}
