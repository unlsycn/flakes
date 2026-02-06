final: prev: {
  lnl-bt-firmware = prev.stdenv.mkDerivation {
    name = "lnl-bt-firmware";

    src = prev.fetchgit {
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
      rev = "575e6573d8f7bc88e33871bcb07292508577e46a";
      hash = "sha256-zL2ck91IBjBw/10YirxfoScEjbvEXVBR7bpLzuF3kDc=";
    };

    installPhase = ''
      mkdir -p $out/lib/firmware/intel
      cp intel/ibt-0190-0291-usb.sfi $out/lib/firmware/intel/
      cp intel/ibt-0190-0291-usb.ddc $out/lib/firmware/intel/
      cp intel/ibt-0190-0291-pci.sfi $out/lib/firmware/intel/
      cp intel/ibt-0190-0291-pci.ddc $out/lib/firmware/intel/
    '';
  };

  lnl-alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (oldAttrs: {
    src = prev.fetchgit {
      url = "https://github.com/alsa-project/alsa-ucm-conf.git";
      rev = "858d3a2443c66a7d5a2b5598308619237e8fc75d";
      sha256 = "sha256-Vds79ITUSZOqg4yf/dnYu2muxrvJuYBpvrtde/7+m9Y=";
    };
    installPhase = ''
      mkdir -p $out/share/alsa
      cp -r ucm2 $out/share/alsa/
    '';
    postInstall = "";
  });
}
