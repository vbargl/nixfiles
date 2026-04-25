{ inputs, ... }:
{
  flake.overlays.jujutsu =
    final: _prev:
    let
      unstable = inputs.unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      inherit (unstable) jujutsu;
    };
}
