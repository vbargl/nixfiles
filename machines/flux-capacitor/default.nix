{ self, inputs, ... }: {
  flake.nixosConfigurations.flux-capacitor = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      self.nixosModules.default

      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko

      ./hardware.nix
      ./disko.nix
      ./config.nix

      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs self; };
      })
    ];
  };
}
