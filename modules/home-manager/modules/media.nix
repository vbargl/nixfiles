{ lib, pkgs, config, ... }:
let
  hasMediaPurpose  = builtins.elem "media" config.purpose;
  hasGuiCapabiltiy = builtins.elem "gui" config.environment.capabilities;

  pkgsSet = [
		pkgs.vlc     # robust media player
		pkgs.mpv     # simple media player
		pkgs.feh     # simple photo viewer
    pkgs.spotify # music streaming
  ];
in
{
  config = lib.mkIf (hasMediaPurpose && hasGuiCapabiltiy) {
    home.packages = pkgsSet;
  };
}
