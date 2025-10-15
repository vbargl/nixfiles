{ lib, pkgs, config, ... }:
let
  hasDevPurpose    = builtins.elem "dev" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = {
    cli = [
      pkgs.jujutsu
      pkgs.git
      pkgs.lazygit
      pkgs.nixd
    ];
    
    gui = [
  		pkgs.vscode
  		pkgs.jetbrains.idea-ultimate
  		pkgs.jetbrains.idea-community
  		pkgs.postman
  		pkgs.realvnc-vnc-viewer
  		pkgs.remmina
  		pkgs.google-chrome
  		pkgs.p11-kit
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
