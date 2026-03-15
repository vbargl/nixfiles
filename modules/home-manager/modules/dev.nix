{ lib, pkgs, config, ... }:
let
  hasDevPurpose    = builtins.elem "dev" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = with pkgs; {
    cli = [
      jujutsu
      git
      git-credential-keepassxc
      lazygit
      nixd
      xvfb-run
  		ngrok
      kind
      nodejs
      pinchtab
    ];
    
    gui = [
  		vscode
  		code-cursor
  		jetbrains.idea
  		jetbrains.goland
  		jetbrains.rider
  		jetbrains.webstorm
  		android-studio
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
