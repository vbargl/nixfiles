{ self, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.ash-twin = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.chaotic.nixosModules.default
      ./config.nix
    ];
  };

  flake.deploy.nodes.ash-twin = {
    hostname = "ash-twin";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [
      "-o"
      "StrictHostKeyChecking=no"
      "-i"
      "/home/vbargl/.ssh/osobni/ash-twin.sshkey"
    ];
    magicRollback = true;
    autoRollback = true;
    confirmTimeout = 300;

    profiles.system.path =
      inputs.deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.ash-twin;
  };
}
