{ inputs, ... }:
{
  flake.overlays.snx-rs =
    final: _prev:
    let
      unstable = inputs.unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      inherit (unstable) snx-rs;
    };
}
