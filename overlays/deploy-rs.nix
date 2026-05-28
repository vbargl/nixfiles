{ inputs, ... }:
{
  flake.overlays.deploy-rs =
    final: _prev:
    let
      unstable = inputs.unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      inherit (unstable) deploy-rs;
    };
}
