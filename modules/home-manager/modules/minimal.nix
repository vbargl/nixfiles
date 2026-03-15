{ lib, pkgs, config, ... }: 
let
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = with pkgs; {
    cli = [
      moreutils
      nmap
      curl
      fzf
      rclone
      dasel
      bat
      btop
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
    ];
  };
in
{
  programs = {
    fish.enable = true;
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
    };
    carapace-specs.enable = true;
    helix = {
      enable = true;
      defaultEditor = true;
    };

    yazi.enable = true;

    zellij = {
      enable = true;

      # TODO: autostart in fish termina
      #       really want just completions only
      #
      # enableFishIntegration = true;
    };

    caelestia = lib.mkIf hasGuiCapability {
      enable = true;
      settings.services.useFahrenheit = false;
      settings.services.useTwelveHourClock = false;
      settings.bar.status.showAudio = true;
    };
  };

  home.packages = lib.mkMerge [
    pkgsSet.cli
    (lib.mkIf hasGuiCapability pkgsSet.gui)
  ];
}
