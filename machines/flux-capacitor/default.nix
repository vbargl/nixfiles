{ self, inputs, ... }: {
  flake.nixosConfigurations.flux-capacitor = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.hjem.nixosModules.hjem
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko

      ./hardware.nix
      ./disko.nix
      ./config.nix

      ../../users/vbargl

    ] ++ (with self.modules.machines; [
      options
      zerotier
    ]) ++ (with self.profiles.machines; [
      minimal
      stylix
    ]) ++ (with self.profiles.users; [
      minimal
      connectivity
      daily
    ]);
  };
}
