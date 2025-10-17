{ self, inputs, lite }:
let
  inherit (inputs) different-error;
  mkPkgs = system: self.lib.importPkgs different-error { inherit system; };
in
{
  packages = lite.systems.each (system:
    let pkgs = mkPkgs system;
    in { inherit (pkgs) nordvpn; }
  );
}
