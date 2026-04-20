{ lib, pkgs, config, ... }:
let cfg = config.nxf.home.wine;
in {
  options.nxf.home.wine.enable = lib.mkEnableOption "Wine + Bottles + winetricks (user tooling)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wineWowPackages.waylandFull
      bottles
      winetricks
    ];
  };
}
