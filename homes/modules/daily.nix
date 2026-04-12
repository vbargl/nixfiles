{ pkgs, lib, hasCapability, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
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

  fonts.fontconfig.enable = true;

  systemd.user.services.syncthing = {
    description = "Syncthing";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing serve --no-browser --config /home/vbargl/.config/syncthing --data /home/vbargl/Sync";
      Restart = "on-failure";
    };
  };
}
