# staging area for packages that need to ride ahead of nixpkgs
final: prev: {
  waybar = prev.waybar.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "09e69e0f48214a1128d62417612bc47e8dc9e36a";
      hash = "sha256-grYWj1RHrkhM0NCIymTsZyObuQsCVf1kuzLaThwMxvc=";
    };

    buildInputs = old.buildInputs ++ [ prev.modemmanager ];

    # master's libcava.wrap wants cava-1.0.0; nixpkgs still injects 0.10.7-beta
    postUnpack = (prev.lib.concatStringsSep "\n" (prev.lib.toList (old.postUnpack or ""))) + ''
      pushd "$sourceRoot"
      cp -R --no-preserve=mode,ownership ${
        prev.fetchFromGitHub {
          owner = "LukashonakV";
          repo = "cava";
          tag = "1.0.0";
          hash = "sha256-0r5aAmTs+FcmS501tNYKxG9H+Pq6i32BDRBEjWW6M74=";
        }
      } subprojects/cava-1.0.0
      popd
    '';
  });
}
