{ self, ... }:
{
  flake.overlays.pinchtab =
    final: _prev:
    let
      pinchtab = final.callPackage "${self.outPath}/packages/pinchtab/package.nix" { };
    in
    {
      inherit pinchtab;
    };
}
