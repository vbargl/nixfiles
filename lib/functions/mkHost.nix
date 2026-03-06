{ self, inputs, ... }:
let
  flake = inputs.self;
  inherit (inputs) nixpkgs disko;
in
{
  lib.mkHost = system: hostPath:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        "${flake}/modules/nixos/services/zerotier"
        hostPath
        { nixpkgs.config = self.config.nixpkgs; }
      ];
    };
}
