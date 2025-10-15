{ self, ... }:
{
  overlays = [
    (final: prev: {
      inherit (self.lib.mkUnstable prev.system) snx-rs;
    })
  ];
}
