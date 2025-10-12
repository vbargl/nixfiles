{ pkgs, ... }: 
{
  programs = {
    fish.enable = true;

    helix = {
      enable = true;
      defaultEditor = true;
    };

    zellij = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  home.packages = with pkgs; [
    moreutils
    nmap
    curl
    lf
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
}