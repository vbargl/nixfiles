{ inputs, ... }:
{
  flake.overlays.deploy-rs =
    final: _prev:
    let
      deploy-rs = inputs.deploy-rs.packages.${final.stdenv.hostPlatform.system};
    in
    {
      deploy-rs = deploy-rs.default;
    };
}
