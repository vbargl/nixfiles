{ inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs { inherit system; };
in
{
  devShells.${system}.default = pkgs.mkShell {
    packages = [
      inputs.deploy-rs.packages.${system}.default
    ];
  };
}
