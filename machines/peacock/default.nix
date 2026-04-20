{ self, inputs, ... }: {
  flake.nixosConfigurations.peacock = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.home-manager.nixosModules.home-manager
      ./config.nix
    ];
  };
}
