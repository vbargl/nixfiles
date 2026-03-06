{ self, inputs, ... }:
let
  linux = "x86_64-linux";
in
{
  nixosConfigurations = {
    ant = self.lib.mkHost linux ./ant;
    peacock = self.lib.mkHost linux ./peacock;
  };
}
