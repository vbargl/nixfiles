{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wineWowPackages.waylandFull
    bottles
    winetricks
  ];
}
