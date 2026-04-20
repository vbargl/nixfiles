{ self, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.ash-twin = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = { inherit inputs self; };

    modules = [
      self.nixosModules.default

      inputs.home-manager.nixosModules.home-manager
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

  flake.deploy.nodes.ash-twin = {
    hostname = "ash-twin";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [ "-o" "StrictHostKeyChecking=no" "-i" "/home/vbargl/.ssh/osobni/ash-twin.sshkey" ];
    magicRollback = true;
    autoRollback = true;
    confirmTimeout = 300;

    profiles.system.path =
      inputs.deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.ash-twin;
  };
}
