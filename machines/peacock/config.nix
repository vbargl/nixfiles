{
  self,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = lib.flatten [
    ./hardware.nix

    self.stacks.baremetal
    self.stacks.desktop
    self.nixosModules.capabilities
    self.nixosModules.stylix
    self.nixosModules.zerotier
    self.nixosModules.snx-rs
    self.nixosModules.localzone
    self.nixosModules.wine
    self.nixosModules.snd_hda_intel

    self.users.vbargl.nixos
    self.userModules.vbargl.nordvpn
  ];

  system.stateVersion = "25.05";

  nixpkgs.overlays = with self.overlays; [
    pinchtab
    jujutsu
    nushell
    rclone
    snx-rs
    nordvpn
    zen-browser
    deploy-rs
  ];

  nxf.machine.capabilities = with self.lib.capabilities; [
    gui
    gpu
    audio
    bluetooth
    virtualization
    zfs
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "snd_hda_intel" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "data" ];

  # VPN services
  nxf.nixos.zerotier.networkIds = [ "b6079f73c6fe0b88" ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Networking
  networking.hostId = "430ec17c";
  networking.hostName = "peacock";
  networking.firewall.enable = false;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Desktop
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.uwsm}/bin/uwsm start -F -- ${config.programs.hyprland.package}/bin/Hyprland";
      user = "vbargl";
    };
  };
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Audio (wireplumber rules — peacock-specific node layout; common pipewire setup in stacks.desktop)
  services.pipewire.wireplumber.extraConfig."10-disable-hdmi-nodes" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-3"; }
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-4"; }
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-5"; }
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-31"; }
          { "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-input-6"; }
        ];
        actions.update-props."node.disabled" = true;
      }
    ];
  };
  services.pipewire.wireplumber.extraConfig."11-rename-nodes" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-output-0"; }
        ];
        actions.update-props."node.description" = "Speakers";
      }
      {
        matches = [
          { "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-input-0"; }
        ];
        actions.update-props."node.description" = "Headset Microphone";
      }
      {
        matches = [
          { "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.pro-input-7"; }
        ];
        actions.update-props."node.description" = "Internal Microphone";
      }
    ];
  };
  hardware.alsa.enablePersistence = true;

  # Hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Security
  security.sudo.extraRules = [
    {
      users = [ "vbargl" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/chvt";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.wrappers.gsr-kms-server = {
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
  };

  boot.loader.systemd-boot.configurationLimit = 10;

  # nix-ld
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl.out
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

  home-manager.users.vbargl = {
    imports = lib.flatten [
      (with self.users.vbargl.profiles; [
        minimal
        gui
        dev
        daily
        vpn
        media
        games
        cluster-management
      ])
      self.users.vbargl.packages.caelestia
      self.users.vbargl.packages.wine
    ];
    home.stateVersion = "25.11";

    nxf.home.caelestia.settings = {
      services.useFahrenheit = lib.mkDefault false;
      services.useTwelveHourClock = lib.mkDefault false;
      bar.status.showAudio = lib.mkDefault true;
      general.apps.explorer = lib.mkDefault [ "dolphin" ];
      general.apps.terminal = lib.mkDefault [ "ghostty" ];
      paths.wallpaperDir = lib.mkDefault "${self}/users/vbargl/assets/wallpapers";
    };
  };

  users.users.vbargl.extraGroups = [
    "input"
    "libvirtd"
    "docker"
    config.nxf.nixos.localzone.group
  ];
}
