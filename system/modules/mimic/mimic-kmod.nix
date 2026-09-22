{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  mimic,
}:

# Repairs skb checksum metadata after Mimic's UDP-to-TCP rewrite.
let
  kernelVersion = kernel.modDirVersion;
  inherit (mimic.passthru) checksumHack;
in
stdenv.mkDerivation {
  pname = "mimic-kmod";
  inherit (mimic) version;
  inherit (mimic.passthru) src;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = [ "all" ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNEL_UNAME=${kernelVersion}"
    "SYSTEM_BUILD_DIR=${kernel.dev}/lib/modules/${kernelVersion}/build"
    "CHECKSUM_HACK=${checksumHack}"
  ];

  buildPhase = ''
    runHook preBuild
    make -C kmod build $makeFlags
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 kmod/mimic.ko $out/lib/modules/${kernelVersion}/misc/mimic.ko
    runHook postInstall
  '';

  meta = {
    description = "Checksum offset fix for the Mimic UDP to TCP obfuscator";
    homepage = "https://github.com/hack3ric/mimic";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
