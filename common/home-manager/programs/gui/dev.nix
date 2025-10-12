{ pkgs, ... }:
{
  home.packages = with pkgs; [
		vscode
		jetbrains.idea-ultimate
		jetbrains.idea-community
		postman
		realvnc-vnc-viewer
		remmina
		google-chrome
		p11-kit
	];
}