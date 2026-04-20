{ pkgs, ... }:
{
  home.packages = [ pkgs.carapace ];

  xdg.configFile."carapace/specs" = {
    source = ../config/carapace;
    recursive = true;
  };
}
