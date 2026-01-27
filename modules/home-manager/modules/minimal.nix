{ lib, pkgs, config, ... }: 
let
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = with pkgs; {
    cli = [
      moreutils
      nmap
      curl
      xplr
      fzf
      rclone
      dasel
      bat
      htop
      gtrash
      zip
      unzip
      fd
      bc
      less
    ];

    gui = [
      ghostty
  		walker      # launcher
  		firefox     # browser
  		thunderbird # email
  		peazip      # archive manager
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
    (lib.mkIf hasGuiCapability pkgsSet.gui)
  ];
}
