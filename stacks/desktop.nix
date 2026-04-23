{
  flake.stacks.desktop =
    { self, ... }:
    {
      imports = [
        self.nixosModules.audio
        self.nixosModules.bluetooth
        self.nixosModules.wifi
      ];
    };
}
