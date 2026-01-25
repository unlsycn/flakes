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
  systemd,
  ...
}:
let
  resholved = resholve.mkDerivation {
    pname = "unlauncher";
    version = "9999";

    src = fetchFromGitHub {
      owner = "unlsycn";
      repo = "Unlauncher";
      rev = "067095fe862688fa735e9f3b72ce1a2d893c746a";
      sha256 = "sha256-c5zxT+CepS4DgSsbJlv2BeeV4fGgVgicvIPHD5+PcOM=";
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
          systemd
        ];
        keep = [ "$in_section" ];
        execer = [
          "cannot:${ripgrep}/bin/rg"
          "cannot:${fzfmenu}/bin/fzfmenu"
          "cannot:${systemd}/bin/systemd-run"
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
