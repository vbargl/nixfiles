{ lib, pkgs, hasCapability, ... }: {
  imports = [ ../nushell ];

  users.users.vbargl.packages = with pkgs; lib.mkMerge [
    [
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
    ]
    (lib.mkIf (hasCapability "gui") [
      ghostty
      walker
      firefox       # kept for compatibility
      thunderbird
      peazip
    ])
  ];

  programs.fish.enable = true;

  hjem.users.vbargl.files =
    lib.mkIf (hasCapability "gui") {
      ".config/mimeapps.list".source = ../../../config/mimeapps.list;
    };
}
