{ self, inputs, ... }: {
  flake.nixosConfigurations.ash-twin = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      self.nixosModules.default

      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.chaotic.nixosModules.default

      ./config.nix

      ({ config, pkgs, lib, ... }: {
        nixpkgs.config = { allowUnfree = true; allowUnfreePredicate = _: true; };
        nixpkgs.overlays = [ self.overlays.default ];

        environment.capabilities.gui = true;

        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "root" "vbargl" ];
        };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs self; };

        system.stateVersion = "25.11";
      })
    ];
  };
}
