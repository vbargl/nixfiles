{ pkgs, lib, hasCapability, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
    wineWowPackages.waylandFull # Wine with native Wayland + 32/64-bit support
    bottles                     # GTK4 GUI manager, isolated prefixes per app
    winetricks                  # CLI installer for Windows components (.NET, VCR, etc.)
  ];
}
