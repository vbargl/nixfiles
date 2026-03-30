{ self, inputs, ... }:
let
  linux = "x86_64-linux";
in
{
  nixosConfigurations = {
    animus = self.lib.mkHost linux ./animus;
    flux-capacitor = self.lib.mkHost linux ./flux-capacitor;
    peacock = self.lib.mkHost linux ./peacock;
  };
}
