{ pkgs, ... }:
{
  home.packages = [ pkgs.zen-browser ];
  xdg.configFile."mimeapps.list".source = ./config/mimeapps.list;
}
