{ pkgs, ... }:
{
  home.packages = with pkgs; [
		vlc # robust media player
		mpv # simple media player
		feh # simple photo viewer
  ];
}
