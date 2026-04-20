{ pkgs, ... }: {
  nxf.home.nushell.enable = true;

  home.packages = with pkgs; [
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
    nh
    fish
    carapace
    yazi
    zellij
  ];

  programs.fish.enable = true;
}
