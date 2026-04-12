{ inputs, ... }: {
  perSystem = { system, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs.deploy-rs.packages.${system}.default
      ];
    };
  };
}
