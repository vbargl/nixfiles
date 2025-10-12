{ self, ... }:
let
  linux = "x86_64-linux";
in
{
  flake.homeConfigurations = {
    desktop = self.lib.mkHome linux [ ./desktop ];
    minimal = self.lib.mkHome linux [ ./minimal ];
  };
}
