{ self, ... }:
{
  flake.homeConfigurations = {
    desktop = self.lib.mkHome "x86_64-linux" [ ./desktop ];
  };
}
