{
  flake.nixosModules.home-manager =
    { self, inputs, ... }:
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs self; };
    };
}
