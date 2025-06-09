final: prev: {
  lnl-bt-firmware = prev.stdenv.mkDerivation {
    name = "lnl-bt-firmware";

    src = prev.fetchgit {
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
      rev = "47bc8a2407426274d099607d5af419cb616d9209";
      hash = "sha256-V581DtceoFuY/GP4eTcq+aACUd+WY+SdtuDUX8UHB+4=";
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
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/421e37b.tar.gz";
      sha256 = "sha256:08rsv6wn32d9zrw1gl2jp7rqzj8m6bdkn0xc7drzf9gfbf6fvmpb";
    };
    installPhase = ''
      mkdir -p $out/share/alsa
      cp -r ucm2 $out/share/alsa/
    '';
    postInstall = "";
  });
}
