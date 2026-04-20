{ inputs, ... }:
{
  flake.overlays.zen-browser =
    final: _prev:
    let
      zen-browser = inputs.zen-browser.packages.${final.stdenv.hostPlatform.system};
    in
    {
      zen-browser = zen-browser.default;
    };
}
