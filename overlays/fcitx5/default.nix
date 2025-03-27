final: prev:
let
  rime-flypy = final.callPackage ./rime-flypy { };
in
{
  fcitx5-rime = prev.fcitx5-rime.override {
    rimeDataPkgs = [
      rime-flypy
      # provide default skeleton
      final.rime-data
    ];
  };
}
