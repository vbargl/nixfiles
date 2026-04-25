{
  flake.stacks.baremetal =
    { self, ... }:
    {
      imports = [
        self.stacks.vm
        self.nixosModules.datetime
        self.nixosModules.printing
        self.nixosModules.power
        self.nixosModules.udisks
      ];
    };
}
