{ lib, pkgs, config, ... }:
let
  hasMediaPurpose  = builtins.elem "media" config.purpose;
  hasGuiCapabiltiy = builtins.elem "gui" config.environment.capabilities;

  pkgsSet = with pkgs; [
		vlc     # robust media player
		mpv     # simple media player
		feh     # simple photo viewer
    spotify # music streaming
  ];
in
{
  config = lib.mkIf (hasMediaPurpose && hasGuiCapabiltiy) {
    home.packages = pkgsSet;
  };
}
