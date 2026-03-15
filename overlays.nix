{ self, inputs, ... }:
{
  overlays.default = final: prev:
    let
      system = final.stdenv.hostPlatform.system;
      config = self.config.nixpkgs;
      unstable = import inputs.unstable { inherit system config; };
    in {
      nordvpn = (import inputs.different-error { inherit system config; }).nordvpn;
      carapace-specs = final.callPackage "${inputs.self}/packages/carapace-specs" {};
      pinchtab = final.callPackage "${inputs.self}/packages/pinchtab" {};
      inherit (unstable) snx-rs nushell;
    };
}
