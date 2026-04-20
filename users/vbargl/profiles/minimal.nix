{ self, pkgs, ... }:
{
  imports = with self.users.vbargl.packages; [
    carapace
    fish
    nushell
  ];

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
    yazi
    zellij
  ];
}
