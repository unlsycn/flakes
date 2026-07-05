final: prev: {
  waybar = prev.waybar.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "e17c0d9f0a73acc370df60ec8c532b1ed2385c73";
      hash = "sha256-p5iqMo4JPhbukRqPlYjciaU89wRPDmWSUY9NkxywI+k=";
    };

    postUnpack = (prev.lib.concatStringsSep "\n" (prev.lib.toList (old.postUnpack or ""))) + ''
      pushd "$sourceRoot"
      if [[ -e subprojects/cava-0.10.7-beta && ! -e subprojects/cava-0.10.7 ]]; then
        ln -s cava-0.10.7-beta subprojects/cava-0.10.7
      fi
      popd
    '';
  });
}
