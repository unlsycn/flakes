{
  resholve,
  fetchFromGitHub,
  bash,
  coreutils,
  jq,
  gnused,
  gnugrep,
  gawk,
  libnotify,
  hyprland,
  pamixer,
  hyprnome,
  ...
}:
resholve.mkDerivation {
  pname = "desktop-scripts";
  version = "9999";

  src = fetchFromGitHub {
    owner = "unlsycn";
    repo = "useful-scripts";
    rev = "f00b49a7295503663939e320072f327afcba55b6";
    fetchSubmodules = false;
    sha256 = "sha256-KwtbzR7W26Vr24UwPqENaRm+FXMlcWUbWU4GTjEwLAw=";
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
    install -m755 switch_layout switch_wallpaper switch_workspace volume "$out/bin"

    runHook postInstall
  '';

  solutions = {
    default = {
      scripts = [
        "bin/switch_layout"
        "bin/switch_wallpaper"
        "bin/switch_workspace"
        "bin/volume"
      ];
      interpreter = "${bash}/bin/bash";
      inputs = [
        coreutils
        jq
        gnused
        gnugrep
        gawk
        libnotify
        hyprland
        pamixer
        hyprnome
      ];
    };
  };

}
