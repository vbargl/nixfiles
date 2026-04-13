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
      firefox       # kept for compatibility
      zen-browser   # default browser
      thunderbird
      peazip
    ])
  ];

  programs.fish.enable = true;

  hjem.users.vbargl.files = lib.mkMerge [
    {
      ".config/nushell/env.nu".source    = ../../config/nushell/env.nu;
      ".config/nushell/config.nu".source = ../../config/nushell/config.nu;
    }
    (lib.mkIf (hasCapability "gui") {
      ".config/mimeapps.list".text = ''
        [Default Applications]
        text/html=zen-beta.desktop
        x-scheme-handler/http=zen-beta.desktop
        x-scheme-handler/https=zen-beta.desktop
        x-scheme-handler/about=zen-beta.desktop
        x-scheme-handler/unknown=zen-beta.desktop
      '';
    })
  ];
}
