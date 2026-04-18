{ self, inputs, ... }: {
  flake.nixosConfigurations.ash-twin = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.hjem.nixosModules.hjem
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.chaotic.nixosModules.default

      ./ash-twin
      ../homes/vbargl.nix

    ] ++ (with self.modules.nixos; [
      options
      minimal
      stylix
      zerotier
      nordvpn
    ]) ++ (with self.modules.homeManager; [
      minimal
      daily
      connectivity
      media
      games
    ]) ++ [({ config, pkgs, lib, ... }: {
      nixpkgs.config = { allowUnfree = true; allowUnfreePredicate = _: true; };
      nixpkgs.overlays = [ self.overlays.default ];

      environment.capabilities.gui = true;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "root" "vbargl" ];
      };

      hjem.users.vbargl.directory = "/home/vbargl";

      system.stateVersion = "25.11";
    })];
  };
}
