{ self, inputs, ... }:
let
  inherit (inputs) home-manager;
  flake = inputs.self;
in
{
  lib.mkHome = system: config:
    home-manager.lib.homeManagerConfiguration {
      pkgs = self.lib.mkPkgs system;  # Use local function instead of self.lib.mkPkgs
      modules = [
        "${flake}/modules/home-manager"
        "${flake}/homes/users/vbargl.nix"
        { inherit config; }
      ];
      extraSpecialArgs = { self = flake; };
    };
}
