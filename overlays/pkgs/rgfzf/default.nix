{
  resholve,
  desktop-scripts,
  bash,
  fzf,
  ripgrep,
  coreutils,
  bat,
  neovim,
  ...
}:
resholve.mkDerivation {
  pname = "desktop-scripts";
  version = "9999";

  src = desktop-scripts.passthru.originalSrc;

  postPatch = ''
    substituteInPlace rgfzf.sh \
      --replace-fail 'rg' '${ripgrep}/bin/rg' \
      --replace-fail 'bat' '${bat}/bin/bat' \
      --replace-fail 'cat' '${coreutils}/bin/cat' \
      --replace-fail 'nvim' '${neovim}/bin/nvim'
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
    install -m755 rgfzf "$out/bin"

    runHook postInstall
  '';

  solutions = {
    default = {
      scripts = [
        "bin/rgfzf"
      ];
      interpreter = "${bash}/bin/bash";
      inputs = [
        coreutils
        fzf
      ];
      execer = [
        "cannot:${fzf}/bin/fzf"
      ];
    };
  };

}
