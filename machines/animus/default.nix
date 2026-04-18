{ inputs, ... }: {
  flake.nixosConfigurations.animus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      ./config.nix
    ];
  };
}
