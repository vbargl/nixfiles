{ self, inputs, ... }: # flake-parts module
{
  config.flake.overlays = self.lib.merge [
    ./packages/snx-rs.nix
  ];
}
