{
  lib,
  stdenv,
  fetchFromGitHub,
  bpftools,
  clang,
  llvmPackages,
  pkg-config,
  libbpf,
  libffi,
}:

let
  checksumHack = "kprobe";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mimic";
  version = "0.7.1-unstable-2026-09-21";

  src = fetchFromGitHub {
    owner = "unlsycn";
    repo = "mimic";
    rev = "fdea0b38c001ebf46ea30aac5163e4aa0a828ab4";
    hash = "sha256-bHtfR2OrQFL7CXPnsE4TPUfNKkCVHFYJAvRQn9ayXho=";
  };

  nativeBuildInputs = [
    bpftools
    clang
    llvmPackages.llvm
    pkg-config
  ];

  buildInputs = [
    libbpf
    libffi
  ];

  # BPF rejects this hardening flag.
  hardeningDisable = [ "zerocallusedregs" ];

  makeFlags = [
    "MODE=release"
    "CHECKSUM_HACK=${checksumHack}"
    "STRIP_BTF_EXT=1"
    "USE_LIBXDP=0"
    "ARGP_STANDALONE=0"
    "BPFTOOL=${lib.getExe' bpftools "bpftool"}"
  ];

  buildFlags = [ "build-cli" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 out/mimic $out/bin/mimic
    runHook postInstall
  '';

  passthru = {
    inherit checksumHack;
    inherit (finalAttrs) src;
  };

  meta = {
    description = "UDP to TCP obfuscator based on eBPF";
    homepage = "https://github.com/hack3ric/mimic";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mimic";
  };
})
