{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  electronVersion = "132";
  version = "11.9.1";
  binary = "better_sqlite3.node";
in
stdenv.mkDerivation {
  pname = "better-sqlite3";
  inherit version;

  src = fetchurl {
    url = "https://github.com/WiseLibs/better-sqlite3/releases/download/v${version}/better-sqlite3-v${version}-electron-v${electronVersion}-linux-x64.tar.gz";
    hash = "sha256-qXbRKNET5qbtO1UFNxpyaeCHE3U2FIDp/J6/DM7cX1k=";
  };

  sourceRoot = "build/Release";

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install ./${binary} $out

    runHook postInstall
  '';
}
