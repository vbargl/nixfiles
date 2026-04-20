{ self, inputs, ... }: {
  flake.nixosConfigurations.animus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      self.nixosModules.default
      inputs.home-manager.nixosModules.home-manager

      ./config.nix

      ({ ... }: {
        nixpkgs.config = { allowUnfree = true; allowUnfreePredicate = _: true; };
        nixpkgs.overlays = [ self.overlays.default ];

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs self; };
      })
    ];
  };
}
