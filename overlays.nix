{ self, inputs, ... }: {
  flake.overlays.default = final: prev:
    let
      system = final.stdenv.hostPlatform.system;
      config = { allowUnfree = true; allowUnfreePredicate = _: true; };
      unstable = import inputs.unstable { inherit system config; };
    in {
      nordvpn = (import inputs.different-error { inherit system config; }).nordvpn;
      carapace-specs = final.callPackage "${self.outPath}/packages/carapace-specs" {};
      pinchtab = final.callPackage "${self.outPath}/packages/pinchtab" {};
      zen-browser = inputs.zen-browser.packages.${system}.default;
      inherit (unstable) snx-rs nushell rclone;
      deploy-rs = inputs.deploy-rs.packages.${system}.default;
    };
}
