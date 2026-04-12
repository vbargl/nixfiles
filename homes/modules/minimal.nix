{ lib, pkgs, hasCapability, ... }: {
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
      nushell
      fish
      carapace
      yazi
      zellij
    ]
    (lib.mkIf (hasCapability "gui") [
      ghostty
      walker
      firefox
      thunderbird
      peazip
    ])
  ];

  programs.fish.enable = true;

  hjem.users.vbargl.files = {
    ".config/nushell/env.nu".source    = ../../config/nushell/env.nu;
    ".config/nushell/config.nu".source = ../../config/nushell/config.nu;
  };
}
