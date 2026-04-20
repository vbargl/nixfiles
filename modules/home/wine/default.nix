{
  flake.homeModules.wine = { pkgs, ... }: {
    home.packages = with pkgs; [
      wineWowPackages.waylandFull
      bottles
      winetricks
    ];
  };
}
