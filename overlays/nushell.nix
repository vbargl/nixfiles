{ inputs, ... }:
{
  flake.overlays.nushell =
    final: _prev:
    let
      unstable = inputs.unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      inherit (unstable) nushell;
    };
}
