{ self, inputs, ... }:
let
  inherit (inputs) deploy-rs nixpkgs;
  system = "x86_64-linux";
in
{
  deploy.nodes.ant = {
    hostname = "ant";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [ "-o" "StrictHostKeyChecking=no" ];
    magicRollback = true;
    autoRollback = true;

    profiles.system = {
      path = deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.ant;
    };
  };

  checks.${system} =
    deploy-rs.lib.${system}.deployChecks self.deploy;
}
