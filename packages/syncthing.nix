{ self, inputs, lite }:
let
  inherit (inputs) unstable nixpkgs;

  mkPkgs = system: self.lib.importPkgs nixpkgs { inherit system; };
in
{
  packages = lite.systems.each (system:
    let pkgs = mkPkgs system;
    in { syncthing = lite.modules.force pkgs.syncthing; }
  );
}
