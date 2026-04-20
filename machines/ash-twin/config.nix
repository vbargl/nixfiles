{ self, config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../profiles/machines/minimal.nix
    ../../profiles/machines/stylix.nix
  ];

  ##################################
  # Boot & kernel
  ##################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # CachyOS kernel + matching ZFS module from chaotic-nyx
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.package = pkgs.zfs_cachyos;   # userspace tooling must match the kernel module
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # zram in place of swap partition
  zramSwap.enable = true;

  ##################################
  # Identity & networking
  ##################################
  networking.hostName = "ash-twin";
  networking.hostId = "83814d0c";                     # required for ZFS; fixed once

  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  # Firewall (explicitly enabled; Steam ports opened via programs.steam.* below)
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # ZeroTier (module adds zt+ to trustedInterfaces automatically)
  nxf.nixos.zerotier = {
    enable = true;
    networkIds = [ "b6079f73c6fe0b88" ];
  };

  # NordVPN (outbound-only; no extra firewall rules needed)
  nxf.nixos.nordvpn.enable = true;

  # Wifi — configured in a second pass once ash-twin's host key is known to agenix.
  # See plan Task 11.

  ##################################
  # Locale & keyboard
  ##################################
  i18n.defaultLocale = "cs_CZ.UTF-8";
  i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";
  console.keyMap = "cz-qwertz";

  services.xserver.xkb = {
    layout = "cz,cz,sk";
    variant = ",bksl,";                   # plain cz (qwertz, primary); cz with \| on bksl; classic sk
    options = "grp:alt_shift_toggle";
  };

  ##################################
  # Users & SSH
  ##################################
  # Extends homes/vbargl.nix — adds input + nordvpn groups and the ash-twin client key.
  users.users.vbargl.extraGroups = [ "input" "nordvpn" ];
  users.users.vbargl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY6gtMnjI0Kdree5NzQirQwostYEA0RiSZCcGp8dKMY ash-twin"
  ];

  security.sudo.extraRules = [{
    users = [ "vbargl" ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Games dataset: ensure ownership after mount
  systemd.tmpfiles.rules = [
    "d /home/vbargl/games 0755 vbargl users -"
  ];

  ##################################
  # Graphics (NVIDIA proprietary + 32-bit for Proton)
  ##################################
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;   # chaotic-nyx's open module fails to build vs cachyos 6.18 (upstream known failure)
    nvidiaSettings = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ##################################
  # Display manager & desktop
  ##################################
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "vbargl";
  };
  services.displayManager.defaultSession = "plasma";   # gamescope session available; launched from Plasma (Steam Big Picture) per-game
  services.desktopManager.plasma6.enable = true;

  ##################################
  # Gaming
  ##################################
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;

  ##################################
  # Audio
  ##################################
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
  };

  ##################################
  # Bluetooth (controllers, headphones)
  ##################################
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  ##################################
  # Secrets (agenix) — wifi wired in second pass (Task 11)
  ##################################
  # age.secrets.wifi-vodafone-psk.file = ../../secrets/wifi-vodafone-psk.age;

  ##################################
  # Misc
  ##################################
  environment.systemPackages = with pkgs; [
    vim
    btop
    curl
    git
    util-linux
  ];

  nxf.users.vbargl = {
    enable = true;
    profiles = with config.nxf.profiles.users; [
      minimal
      daily
      connectivity
      media
      games
    ];
  };
}
