{ self, inputs, lite }@moduleInputs:
let
  flake = inputs.self;
  inherit (inputs) home-manager nixpkgs;

  mkPkgs = system: self.lib.importPkgs nixpkgs { inherit system; };

  vbarglModule = import "${flake}/homes/users/vbargl.nix" moduleInputs;
in
{
  lib.mkHome = system: config:
    let
      pkgs = mkPkgs system;
      pkgsAndOverlay = self.packages.${system};
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
       
      extraSpecialArgs = {
        self = flake;
        pkgs = pkgsAndOverlay;
      };
      
      modules = [
        "${flake}/modules/home-manager"
        vbarglModule
        { inherit config; }
      ];
    };
}
