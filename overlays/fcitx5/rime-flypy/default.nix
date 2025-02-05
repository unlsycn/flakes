{
  stdenvNoCC,
  fetchFromGitHub,
  librime,
  rime-data,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-flypy";
  version = "9999";
  src = fetchFromGitHub {
    owner = "cubercsl";
    repo = "rime-flypy";
    rev = "c3e14514dc5ef0471706c31f67e51f28a8cf225b";
    sha256 = "sha256-Ttb9Hf97un+YtxEiFWiMePLk1xMe8oMAhDJs6ZWY+PA=";
  };

  nativeBuildInputs = [
    librime
    rime-data
  ];

  # this repo just contains flypy schemas without default.yaml, we use librime to compile them with rime-data
  postUnpack = ''
    cp ${rime-data}/share/rime-data/. -r $sourceRoot
  '';

  makeFlags = [ "PREFIX=$(out)" ];
}
