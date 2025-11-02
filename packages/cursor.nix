{ self, inputs, lite }:
let
  inherit (inputs) unstable;
  mkPkgs = system: self.lib.importPkgs unstable { inherit system; };
in
{
  packages = lite.systems.each (system:
    let pkgs = mkPkgs system;
    in
    {
      code-cursor = lite.modules.force pkgs.code-cursor;
      cursor-cli = lite.modules.force pkgs.cursor-cli;
    }
  );
}
