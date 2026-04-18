{ self, inputs, ... }:
let
  inherit (inputs) deploy-rs;
  system = "x86_64-linux";
in
{
  flake.deploy.nodes.flux-capacitor = {
    hostname = "flux-capacitor";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [ "-o" "StrictHostKeyChecking=no" ];
    magicRollback = true;
    autoRollback = true;
    confirmTimeout = 300;

    profiles.system = {
      path = deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.flux-capacitor;
    };
  };

  flake.deploy.nodes.ash-twin = {
    hostname = "ash-twin";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [ "-o" "StrictHostKeyChecking=no" "-i" "/home/vbargl/.ssh/osobni/ash-twin.sshkey" ];
    magicRollback = true;
    autoRollback = true;
    confirmTimeout = 300;

    profiles.system = {
      path = deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.ash-twin;
    };
  };

  perSystem = { system, ... }: {
    checks = deploy-rs.lib.${system}.deployChecks self.deploy;
  };
}
