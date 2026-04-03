# Minimal hardware config for VM; build-vm overrides this at runtime
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
