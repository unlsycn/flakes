{
  pkgs,
  ...
}:
let
  caKeyEncPath = ./ca.key.admin;
  caCrtPath = ./ca.crt;
in
pkgs.writeShellApplication {
  name = "update-nebula-certs";
  runtimeInputs = with pkgs; [
    jq
    sops
    nebula
    git
    coreutils
    nix
  ];
  text = ''
    set -e

    CA_KEY_ENC="${caKeyEncPath}"
    CA_CRT="${caCrtPath}"
    LOCK_FILE="nebula-topology.lock"

    echo "Evaluating mesh topology..."
    NEW_TOPOLOGY=$(nix eval .#mesh-topology --apply 't: builtins.mapAttrs (_: v: { inherit (v) ip cidr system; groups = v.roles; }) t' --json)

    if [ -f "$LOCK_FILE" ]; then
      OLD_TOPOLOGY=$(cat "$LOCK_FILE")
    else
      OLD_TOPOLOGY="{}"
    fi

    UPDATED=0
    for HOST in $(echo "$NEW_TOPOLOGY" | jq -r 'keys[]'); do
      NEW_CONFIG=$(echo "$NEW_TOPOLOGY" | jq -c --arg h "$HOST" '.[$h]')
      OLD_CONFIG=$(echo "$OLD_TOPOLOGY" | jq -c --arg h "$HOST" '.[$h] // empty')
      
      SYSTEM=$(echo "$NEW_CONFIG" | jq -r '.system')
      OUT_DIR="system/hosts/$SYSTEM/$HOST/_generated"
      
      NEEDS_UPDATE=0
      if [ "$NEW_CONFIG" != "$OLD_CONFIG" ]; then
        NEEDS_UPDATE=1
      elif [ ! -f "$OUT_DIR/nebula.crt" ] || [ ! -f "$OUT_DIR/nebula.key" ] || [ ! -f "$OUT_DIR/nebula_ca.crt" ]; then
        NEEDS_UPDATE=1
      fi

      if [ "$NEEDS_UPDATE" -eq 1 ]; then
        echo "Updating certs for $HOST..."
        IP=$(echo "$NEW_CONFIG" | jq -r '.ip')
        CIDR=$(echo "$NEW_CONFIG" | jq -r '.cidr')
        MASK=$(echo "$CIDR" | cut -d/ -f2)
        HOST_GROUPS=$(echo "$NEW_CONFIG" | jq -r '.groups | join(",")')
        CA_KEY_DATA=$(sops --decrypt "$CA_KEY_ENC")
        
        mkdir -p "$OUT_DIR"
        rm -f "$OUT_DIR/nebula.key" "$OUT_DIR/nebula.crt" "$OUT_DIR/nebula_ca.crt"

        nebula-cert sign \
          -ca-crt "$CA_CRT" \
          -ca-key <(echo "$CA_KEY_DATA") \
          -name "$HOST" \
          -ip "$IP/$MASK" \
          -groups "$HOST_GROUPS" \
          -out-crt "$OUT_DIR/nebula.crt" \
          -out-key "$OUT_DIR/nebula.key" 1>/dev/null

        cp "$CA_CRT" "$OUT_DIR/nebula_ca.crt"
        sops --encrypt --output-type=binary --in-place "$OUT_DIR/nebula.key"

        UPDATED=1
      fi
    done

    if [ "$UPDATED" -eq 1 ] || [ "$NEW_TOPOLOGY" != "$OLD_TOPOLOGY" ]; then
      echo "$NEW_TOPOLOGY" > "$LOCK_FILE"
      
      echo "======================================================================"
      echo "Nebula certificates have been successfully generated."
      echo "As files were modified, this commit has been aborted."
      echo "Please review the changes and commit again."
      echo "======================================================================"
      exit 1
    fi
    exit 0
  '';
}
