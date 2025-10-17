{ self, inputs, ... }:
let
  flake = inputs.self;
  inherit (inputs) home-manager nixpkgs;
in
{
  lib.mkHome = system: config:
    home-manager.lib.homeManagerConfiguration {
      # Code below does not really work.
      # I though home-manager will respect it
      # but unfortunately it does not.
      # It is passed as extraSpecialArgs
      # 
      # pkgs = self.packages.${system};
      pkgs = self.lib.importPkgs nixpkgs { inherit system; };
       
      extraSpecialArgs = {
        self = flake;
        pkgs = self.packages.${system};
      };
      
      modules = [
        "${flake}/modules/home-manager"
        "${flake}/homes/users/vbargl.nix"
        { inherit config; }
      ];
    };
}
