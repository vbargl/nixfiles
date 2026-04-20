{ pkgs, ... }: {
  home.packages = with pkgs; [
    wl-clipboard
    alsa-utils
    xwayland
    hyprland
    pavucontrol
    hyprlock
    hypridle
    hyprsysteminfo
    hyprcursor
    xdg-desktop-portal-hyprland
    brightnessctl
    playerctl
    pamixer
    libnotify
    grim
    slurp
    swappy
    gpu-screen-recorder
    kdePackages.dolphin
    keepassxc
    winbox4
    rustdesk
    onlyoffice-desktopeditors
    nerd-fonts.jetbrains-mono
  ];

  systemd.user.services.syncthing = {
    Unit.Description = "Syncthing";
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing serve --no-browser --config %h/.config/syncthing --data %h/Sync";
      Restart = "on-failure";
    };
  };
}
