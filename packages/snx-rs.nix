{ self, inputs, lite}:
let
  inherit (inputs) unstable;

  mkPkgs = system: self.lib.importPkgs unstable { inherit system; };
in
{
  packages = lite.systems.each (system:
    let pkgs = mkPkgs system;
    in { snx-rs = lite.modules.force pkgs.snx-rs; }
  );
}
