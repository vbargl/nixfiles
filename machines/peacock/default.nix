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

  # VPN services
  modules.zerotier = {
    enable = true;
    networkIds = [ "b6079f73c6fe0b88" ];
  };
  modules.snx-rs.enable = true;
  modules.nordvpn.enable = true;

  # Networking
  networking.hostId = "430ec17c";
  networking.hostName = "peacock";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];
  networking.firewall.enable = false;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  networking.extraHosts = ''
    127.0.0.1    eopng-test-master
    127.0.0.1    eopng-test-site1
    127.0.0.1    eopng-test-site2
  '';

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

  # Hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # User
  users.users.vbargl = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" "video" "input" "audio" "libvirtd" "docker" "networkmanager" "nordvpn" ];
  };

  environment.shells = [ pkgs.nushell ];

  # Security
  security.sudo.extraRules = [{
    users = [ "vbargl" ];
    commands = [{
      command = "/run/current-system/sw/bin/chvt";
      options = [ "NOPASSWD" ];
    }];
  }];

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

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.vbargl = {
      imports = [
        "${inputs.self}/modules/home-manager"
        "${inputs.self}/homes/users/vbargl.nix"
        inputs.caelestia-shell.homeManagerModules.default
      ];
      environment.capabilities = [ "gui" ];
      purpose = [ "daily" "dev" "connectivity" "media" "games" "cluster-management" ];
    };
  };

  system.stateVersion = "25.05";
}
