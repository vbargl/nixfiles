{ lib, config, ... }:
let
  cfg = config.nxf.nixos.snd_hda_intel;
in
{
  options.nxf.nixos.snd_hda_intel.enable =
    lib.mkEnableOption "snd_hda_intel module overrides";

  config = lib.mkIf cfg.enable {
    environment.etc."modprobe.d/snd_hda_intel.conf".source = ./config/snd_hda_intel.conf;
  };
}
