{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "snd_hda_intel" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "data" ];

  environment.etc."modprobe.d/snd_hda_intel.conf".text = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  # Networking
  networking.hostId = "430ec17c";
  networking.hostName = "peacock";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];
  networking.firewall.enable = false;

  services.resolved.enable = true;

  # Desktop
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.hyprland}/bin/Hyprland";
      user = "vbargl";
    };
  };
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  programs.hyprland.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    wireplumber.extraConfig."10-disable-hdmi-nodes" = {
      "monitor.alsa.rules" = [{
        matches = [
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-3"; }
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-4"; }
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-5"; }
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-31"; }
          { "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-input-6"; }
        ];
        actions.update-props."node.disabled" = true;
      }];
    };
    wireplumber.extraConfig."11-rename-nodes" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-0"; }];
          actions.update-props."node.description" = "Speakers";
        }
        {
          matches = [{ "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-input-0"; }];
          actions.update-props."node.description" = "Headset Microphone";
        }
        {
          matches = [{ "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-input-7"; }];
          actions.update-props."node.description" = "Internal Microphone";
        }
      ];
    };
  };
  hardware.alsa.enablePersistence = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # User
  users.users.vbargl = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "video" "input" "audio" "libvirtd" "docker" "networkmanager" "nordvpn" ];
  };

  # Security
  security.sudo.extraRules = [{
    users = [ "vbargl" ];
    commands = [{
      command = "/run/current-system/sw/bin/chvt";
      options = [ "NOPASSWD" ];
    }];
  }];

  # Services
  services.automatic-timezoned.enable = true;
  services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  services.envfs.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  services.printing.enable = true;

  # nix-ld
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
      docker
      virtiofsd
    ];
  };

  # Virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      vhostUserPackages = [ pkgs.virtiofsd ];
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  virtualisation.docker.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  # Overlays
  nixpkgs.overlays = [
    (final: prev: {
      nordvpn = (import inputs.different-error {
        system = "x86_64-linux";
        config = { allowUnfree = true; allowUnfreePredicate = _: true; };
      }).nordvpn;
      snx-rs = (import inputs.unstable {
        system = "x86_64-linux";
        config = { allowUnfree = true; allowUnfreePredicate = _: true; };
      }).snx-rs;
    })
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    wl-clipboard
    alsa-utils
    xwayland
    hyprland
    pavucontrol
    hyprlock
    hypridle
    hyprsysteminfo
    hyprcursor
    hyprshot
    xdg-desktop-portal-hyprland
    brightnessctl
    playerctl
    pamixer
    networkmanager-openvpn
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Programs
  programs.fish.enable = true;

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; self = inputs.self; };
    users.vbargl = {
      imports = [
        "${inputs.self}/modules/home-manager"
        "${inputs.self}/homes/users/vbargl.nix"
        inputs.caelestia-shell.homeManagerModules.default
      ];
      environment.capabilities = [ "gui" ];
      purpose = [ "daily" "dev" "connectivity" "media" "games" ];
      programs.caelestia.settings.general.apps.explorer = [ "yazi" ];
      programs.caelestia.settings.general.apps.terminal = [ "ghostty" ];

      systemd.user.services.caelestia-disable-gamemode = {
        Unit = {
          Description = "Disable Caelestia game mode on boot";
          After = [ "caelestia.service" ];
          Requires = [ "caelestia.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = let
            caelestia = inputs.caelestia-shell.packages.x86_64-linux.default;
          in "${pkgs.writeShellScript "disable-gamemode" ''
            ${pkgs.coreutils}/bin/sleep 2
            ${caelestia}/bin/caelestia-shell ipc call gameMode disable
          ''}";
        };
        Install.WantedBy = [ "caelestia.service" ];
      };
      home.file."Pictures/Wallpapers/wallpaper.jpg".source = ./wallpapers/wallpaper.jpg;
    };
  };

  system.stateVersion = "25.05";
}
