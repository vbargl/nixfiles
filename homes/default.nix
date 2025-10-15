{ self, ... }:
let
  linux = "x86_64-linux";
in
{
  homeConfigurations = {
    minimal = self.lib.mkHome linux {
      purpose = [ "conectivity" ];
    };
    desktop = self.lib.mkHome linux {
      environment.capabilities = [ "gui" ];
      purpose = [ "daily" "dev" "connectivity" "media" "games" ];
    };
  };
}
