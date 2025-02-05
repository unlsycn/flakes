_:
(
  self: super:
  let
    rime-flypy = self.callPackage ./rime-flypy { };
  in
  {
    fcitx5-rime = super.fcitx5-rime.override {
      rimeDataPkgs = [
        rime-flypy
        # provide default skeleton
        self.rime-data
      ];
    };
  }
)
