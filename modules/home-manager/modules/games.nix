{ lib, pkgs, config, ... }:
let
  hasGamesPurpose  = builtins.elem "games" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;

  pkgsSet = with pkgs; [
    steam        # gaming platform
    moonlight-qt # streaming service for games
  ];
in
{
  config = lib.mkIf (hasGamesPurpose && hasGuiCapability) {
    home.packages = pkgsSet;
  };
}
