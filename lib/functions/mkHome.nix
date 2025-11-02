{ self, inputs, lite }@moduleInputs:
let
  flake = inputs.self;
  inherit (inputs) home-manager nixpkgs;

  mkPkgs = system: self.lib.importPkgs nixpkgs { inherit system; };

  vbarglModule = import "${flake}/homes/users/vbargl.nix" moduleInputs;
in
{
  lib.mkHome = system: config:
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
       
      extraSpecialArgs = {
        self = flake;
        pkgs = self.packages.${system};
      };
      
      modules = [
        "${flake}/modules/home-manager"
        vbarglModule
        { inherit config; }
      ];
    };
}
