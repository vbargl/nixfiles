{ lib, pkgs, config, ... }:
let
  hasDevPurpose    = builtins.elem "dev" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = with pkgs; {
    cli = [
      jujutsu
      git
      lazygit
      nixd
      xvfb-run
  		cursor-cli
    ];
    
    gui = [
  		vscode
  		code-cursor
  		jetbrains.idea-ultimate
  		jetbrains.idea-community
  		postman
  		realvnc-vnc-viewer
  		remmina
  		google-chrome
  		p11-kit
  	];
  };
in
{
  config = lib.mkIf hasDevPurpose {
    
    programs = {
      # enable with update to 25.11
      # jjui = {
      #   enable = true;
      # };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    home.packages = lib.mkMerge [
      pkgsSet.cli
      (lib.mkIf hasGuiCapability pkgsSet.gui)
    ];
  };
}
