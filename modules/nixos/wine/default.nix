{ lib, config, ... }:
let
  cfg = config.nxf.nixos.wine;
in
{
  options.nxf.nixos.wine = {
    enable = lib.mkEnableOption "Wine 32-bit GPU support";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable32Bit = true;
  };
}
