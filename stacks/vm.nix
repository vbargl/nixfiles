{
  flake.stacks.vm =
    { self, ... }:
    {
      imports = [
        self.nixosModules.nix
        self.nixosModules.home-manager
      ];

      services.envfs.enable = true;
    };
}
