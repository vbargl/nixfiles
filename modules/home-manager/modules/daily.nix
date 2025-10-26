{ lib, pkgs, config, ... }:
let
  hasDevPurpose    = builtins.elem "daily" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;

  pkgsSet = with pkgs; [
    keepassxc # password manager 
    winbox4   # microtik manager
		rustdesk  # remote desktop manager 
  ];
in
{
  config = lib.mkIf (hasDevPurpose && hasGuiCapability) {
    home.packages = pkgsSet;

    services.syncthing = {
    	enable = true;
    	package = pkgs.syncthing;
    	extraOptions = [
    	  "--config" "/home/vbargl/.config/syncthing"
    	  "--data" "/home/vbargl/Sync"
    	];
    };
  };
}
