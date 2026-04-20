{ self, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.flux-capacitor = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      ./config.nix
    ];
  };

  flake.deploy.nodes.flux-capacitor = {
    hostname = "flux-capacitor";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [
      "-o"
      "StrictHostKeyChecking=no"
    ];
    magicRollback = true;
    autoRollback = true;
    confirmTimeout = 300;

    profiles.system.path =
      inputs.deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.flux-capacitor;
  };
}
