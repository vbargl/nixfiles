{ pkgs, hasCapability, lib, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
    vlc
    mpv
    feh
    spotify
  ];
}
