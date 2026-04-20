{ lib, pkgs, config, ... }:
let cfg = config.nxf.home.zen-browser;
in {
  options.nxf.home.zen-browser.enable = lib.mkEnableOption "zen-browser";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.zen-browser ];
    xdg.configFile."mimeapps.list".source = ./config/mimeapps.list;
  };
}
