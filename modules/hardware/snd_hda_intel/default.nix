{
  flake.nixosModules.snd_hda_intel =
    { ... }:
    {
      environment.etc."modprobe.d/snd_hda_intel.conf".source = ./config/snd_hda_intel.conf;
    };
}
