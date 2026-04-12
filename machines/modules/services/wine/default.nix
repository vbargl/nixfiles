{ lib, config, ... }:
let
  cfg = config.modules.wine;
in
{
  options.modules.wine = {
    enable = lib.mkEnableOption "Wine 32-bit GPU support";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable32Bit = true;
  };
}
