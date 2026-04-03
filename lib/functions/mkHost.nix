{ self, inputs, ... }:
let
  flake = inputs.self;
  inherit (inputs) nixpkgs disko home-manager;
in
{
  lib.mkHost = system: hostPath:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        "${flake}/modules/nixos/minimal.nix"
        "${flake}/modules/nixos/services/zerotier"
        "${flake}/modules/nixos/services/snx-rs"
        "${flake}/modules/nixos/services/nordvpn"
        hostPath
        {
          nixpkgs.config = self.config.nixpkgs;
          nixpkgs.overlays = [ self.overlays.default ];
          home-manager.extraSpecialArgs = { inherit inputs; self = inputs.self; };
        }
      ];
    };
}
