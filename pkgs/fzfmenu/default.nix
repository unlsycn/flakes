{
  resholve,
  fetchFromGitHub,
  bash,
  coreutils,
  ripgrep,
  hyprland,
  alacritty,
  ...
}:
resholve.mkDerivation {
  pname = "fzfmenu";
  version = "9999";

  src = fetchFromGitHub {
    owner = "unlsycn";
    repo = "fzfmenu";
    rev = "74c878f12464a86457463afc8304ede7a3c322bb";
    sha256 = "sha256-fVC70edXm4Xan9/yeMg2CNGRIix0C1Lf6PpoWsf5q+c=";
  };

  postPatch = ''
    substituteInPlace fzfmenu.sh \
      --replace-fail '-e bash' '-e ${bash}/bin/bash'
  '';

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
    install -m755 fzfmenu "$out/bin"

    runHook postInstall
  '';

  solutions = {
    default = {
      scripts = [
        "bin/fzfmenu"
      ];
      interpreter = "${bash}/bin/bash";
      inputs = [
        coreutils
        ripgrep
        hyprland
        alacritty
      ];
      execer = [
        "cannot:${ripgrep}/bin/rg"
        "cannot:${alacritty}/bin/alacritty"
      ];
    };
  };

}
