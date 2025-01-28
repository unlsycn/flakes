{
  lib,
  stdenv,
  resholve,
  fetchFromGitHub,
  bash,
  fzfmenu,
  coreutils,
  ripgrep,
  gnused,
  gawk,
  findutils,
  fre,
  hyprland,
  ...
}:
let
  resholved = resholve.mkDerivation {
    pname = "unlauncher";
    version = "9999";

    src = fetchFromGitHub {
      owner = "unlsycn";
      repo = "Unlauncher";
      rev = "facb29fd1673ca6ea62d9024a0ae149fa3a63aff";
      sha256 = "sha256-kotTgrWQPEP9SP1uVXnM/vcpA5Y2VVJQw80GuQ0KCbA=";
    };

    buildPhase = ''
      runHook preBuild

      for file in *.sh; do
        mv "$file" "''${file%.sh}"
      done

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -m755 unlauncher "$out/bin"

      mkdir -p $out/usr/share/unlauncher
      install -m644 hyprland.conf "$out/usr/share/unlauncher"

      runHook postInstall
    '';

    solutions = {
      default = {
        scripts = [
          "bin/unlauncher"
        ];
        interpreter = "${bash}/bin/bash";
        inputs = [
          coreutils
          ripgrep
          fzfmenu
          gnused
          gawk
          findutils
          fre
          hyprland
        ];
        keep = [ "$in_section" ];
        execer = [
          "cannot:${ripgrep}/bin/rg"
          "cannot:${fzfmenu}/bin/fzfmenu"
        ];
      };
    };
  };
in
# resholve creates a new derivation to resolve things, and it prevents us from patching hyprland.conf with $out, so we create another new derivation to fix it up
lib.extendDerivation true resholved.passthru (
  stdenv.mkDerivation {
    src = resholved;
    version = resholved.version;
    pname = "${resholved.pname}-fixed";

    passthru = resholved.passthru // {
      resholved = resholved;
      originalSrc = resholved.src;
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      cp -R $src $out
    '';

    fixupPhase = ''
      substituteInPlace $out/usr/share/unlauncher/hyprland.conf \
        --replace-fail "~/.scripts/bin/unlauncher" "$out/bin/unlauncher"
    '';

    meta = resholved.meta;
  }
)
