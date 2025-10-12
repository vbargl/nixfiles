{ self, inputs, ...}:
let 
  nixpkgs = inputs.nixpkgs;
in
{
  mkPkgs = system: (import nixpkgs {
    inherit system; 
    config = import "${self}/common/nixpkgs-config.nix";
    overlays = [
      self.overlays.snx-rs
    ];
  });
}
