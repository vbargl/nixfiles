{ self, inputs, ... }:
{
  flake.overlays.nordvpn =
    final: _prev:
    let
      different-error = import inputs.different-error {
        inherit (final.stdenv.hostPlatform) system;
        config = self.nixconfig;
      };
    in
    {
      inherit (different-error) nordvpn nordvpn-gui;
    };
}
