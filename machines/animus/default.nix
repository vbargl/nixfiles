{ self, inputs, ... }:
{
  flake.nixosConfigurations.animus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.home-manager.nixosModules.home-manager

      ./config.nix

      (
        { ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs self; };
        }
      )
    ];
  };
}
