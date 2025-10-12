{ self, inputs, ... }:
{
  # This overlay adds the snx-rs package from the unstable channel
  snx-rs = final: prev: {
    # Use the snx-rs package from nixpkgs-unstable
    snx-rs = inputs.nixunstable.legacyPackages.${prev.system}.snx-rs;
  };
}