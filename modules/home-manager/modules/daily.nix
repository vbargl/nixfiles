{ lib, pkgs, config, options, ... }:
let
  hasDailyPurpose  = builtins.elem "daily" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  hasCaelestia     = options.programs ? caelestia;

  pkgsSet = with pkgs; [
    # Desktop environment
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

    # Screenshots & recording
    grim
    slurp
    swappy
    gpu-screen-recorder

    # File management
    kdePackages.dolphin

    # Productivity
    keepassxc                  # password manager
    winbox4                    # microtik manager
    rustdesk                   # remote desktop manager
    onlyoffice-desktopeditors  # office suite
  ];
in
{
  config = lib.mkIf (hasDailyPurpose && hasGuiCapability) {
    home.packages = pkgsSet ++ [
      pkgs.nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig.enable = true;

    programs = lib.optionalAttrs hasCaelestia {
      caelestia = {
        enable = true;
        settings.services.useFahrenheit = false;
        settings.services.useTwelveHourClock = false;
        settings.bar.status.showAudio = true;
      };
    };

    services.syncthing = {
      enable = true;
      package = pkgs.syncthing;
      extraOptions = [
        "--config" "/home/vbargl/.config/syncthing"
        "--data" "/home/vbargl/Sync"
      ];
    };
  };
}
