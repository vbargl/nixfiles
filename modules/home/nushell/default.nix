{ lib, pkgs, config, ... }:
let cfg = config.nxf.home.nushell;
in {
  options.nxf.home.nushell.enable = lib.mkEnableOption "nushell";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nushell ];

    xdg.configFile."nushell/env.nu".source    = ./config/env.nu;
    xdg.configFile."nushell/config.nu".source = ./config/config.nu;
  };
}
