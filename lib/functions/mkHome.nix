{ self, inputs, ... }: # flake-parts module
let
  home-manager = inputs.home-manager;

in
{
  mkHome = system: modules:
    home-manager.lib.homeManagerConfiguration {
      inherit modules;
      pkgs = self.lib.mkPkgs system;
      extraSpecialArgs = inputs;
    };
}
