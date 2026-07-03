{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "seed-foundryvtt-zip";
  runtimeInputs = with pkgs; [
    coreutils
    nix
    openssh
  ];
  text = ''
    set -euo pipefail

    usage() {
      echo "Usage: seed-foundryvtt-zip ZIP_PATH CACHE_HOST"
      echo
      echo "CACHE_HOST may be root@host or an ssh:// URI."
      echo "The zip is added as a fixed-output store path, copied to CACHE_HOST,"
      echo "and rooted under /nix/var/nix/gcroots/foundryvtt on that host."
    }

    if [ "''${1:-}" = "-h" ] || [ "''${1:-}" = "--help" ]; then
      usage
      exit 0
    fi

    if [ "$#" -ne 2 ]; then
      usage >&2
      exit 64
    fi

    zip_path="$1"
    cache_host="$2"

    if [ ! -f "$zip_path" ]; then
      echo "Zip file does not exist: $zip_path" >&2
      exit 66
    fi

    case "$(basename "$zip_path")" in
      FoundryVTT-*.zip) ;;
      *)
        echo "Expected a FoundryVTT zip, got: $(basename "$zip_path")" >&2
        exit 65
        ;;
    esac

    case "$cache_host" in
      ssh://*)
        nix_target="$cache_host"
        ssh_target="''${cache_host#ssh://}"
        ;;
      *)
        nix_target="ssh://$cache_host"
        ssh_target="$cache_host"
        ;;
    esac

    echo "Adding fixed-output zip to the local store..."
    hash=$(nix hash file "$zip_path")
    store_path=$(nix-store --add-fixed sha256 "$zip_path")
    store_name=$(basename "$store_path")

    echo "Copying $store_path to $nix_target..."
    nix copy --to "$nix_target" "$store_path"

    remote_root_dir="/nix/var/nix/gcroots/foundryvtt"
    remote_root="$remote_root_dir/$store_name"

    echo "Creating GC root on $ssh_target..."
    # Paths are computed locally, then passed to the remote shell intentionally.
    # shellcheck disable=SC2029
    ssh "$ssh_target" "
      set -e
      mkdir -p '$remote_root_dir'
      nix-store --add-root '$remote_root' --realise '$store_path' >/dev/null
      nix-store --check-validity '$store_path'
    "

    echo "Seeded FoundryVTT zip."
    echo "Hash: $hash"
    echo "Store path: $store_path"
    echo "Remote GC root: $ssh_target:$remote_root"
  '';
}
