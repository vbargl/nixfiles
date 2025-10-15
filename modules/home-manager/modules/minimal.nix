{ lib, pkgs, config, ... }: 
let
  hasGuiCapabilities = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = {
    cli = [
      pkgs.moreutils
      pkgs.nmap
      pkgs.curl
      pkgs.xplr
      pkgs.fzf
      pkgs.rclone
      pkgs.dasel
      pkgs.bat
      pkgs.htop
      pkgs.gtrash
      pkgs.zip
      pkgs.unzip
      pkgs.fd
      pkgs.bc
      pkgs.less
    ];

    gui = [
  		pkgs.walker      # launcher
  		pkgs.firefox     # browser
  		pkgs.thunderbird # email
  		pkgs.peazip      # archive manager
  		# waybar		  # status bar
  		# mako		    # notification daemon
    ];
  };
in
{
  programs = {
    fish.enable = true;

    helix = {
      enable = true;
      defaultEditor = true;
    };

    zellij = {
      enable = true;

      # TODO: autostart in fish termina
      #       really want just completions only
      #  
      # enableFishIntegration = true;
    };
  };

  home.packages = lib.mkMerge [
    pkgsSet.cli
    (lib.mkIf hasGuiCapabilities pkgsSet.gui)
  ];
}
