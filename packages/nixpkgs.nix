{ self, inputs, lite }:
let
  inherit (inputs) nixpkgs;

  mkPkgs = system: self.lib.importPkgs nixpkgs { inherit system; };
in
{
  packages = lite.systems.each (system: mkPkgs system);
}
