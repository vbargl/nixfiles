{ lib, pkgs, config, ... }:
let
  hasDevPurpose    = builtins.elem "daily" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;

  pkgsSet = [
    pkgs.keepassxc # password manager 
    pkgs.winbox4   # microtik manager
		pkgs.rustdesk  # remote desktop manager 
  ];
in
{
  config = lib.mkIf (hasDevPurpose && hasGuiCapability) {
    home.packages = pkgsSet;
  };
}
