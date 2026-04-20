{ pkgs, ... }: {
  nxf.home.nushell.enable = true;
  nxf.home.zen-browser.enable = true;

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
    ghostty
    walker
    firefox
    thunderbird
    peazip
  ];

  programs.fish.enable = true;
}
