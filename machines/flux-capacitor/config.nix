{
  config,
  pkgs,
  self,
  lib,
  ...
}:
{
  imports = lib.flatten [
    ./hardware.nix
    ./disko.nix
    self.nixosModules.capabilities
    self.users.vbargl.nixos
    self.stacks.baremetal
    self.nixosModules.wifi
    self.nixosModules.stylix
    self.nixosModules.zerotier
  ];

  nixpkgs.overlays = with self.overlays; [
    pinchtab
    nushell
    rclone
    snx-rs
    nordvpn
    zen-browser
  ];

  nxf.machine.capabilities = with self.lib.capabilities; [
    gui
    wifi
  ];

  nxf.nixos.zerotier.networkIds = [ "b6079f73c6fe0b88" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "dm_crypt" ];

  networking.hostName = "flux-capacitor";
  networking.networkmanager.ensureProfiles.environmentFiles = [
    config.age.secrets.wifi-vodafone-psk.path
  ];
  networking.networkmanager.ensureProfiles.profiles.vodafone = {
    connection = {
      id = "Vodafone-D064";
      type = "wifi";
      interface-name = "wlo1";
    };
    wifi = {
      mode = "infrastructure";
      ssid = "Vodafone-D064";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "$WIFI_VODAFONE_PSK";
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };

  age.secrets.wifi-vodafone-psk.file = ../../secrets/wifi-vodafone-psk.age;
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

  i18n.defaultLocale = "cs_CZ.UTF-8";
  i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";
  console.keyMap = "cz-qwertz";

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "vbargl";
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "cz";
    variant = "qwerty";
  };

  security.sudo.extraRules = [
    {
      users = [ "vbargl" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.age.secrets.k3s-token.path;
    extraFlags = [ "--tls-san=172.27.27.9" ];
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2026-03.net.barglvojtech:flux-capacitor";
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
  ];

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    btop
    curl
    git
    nfs-utils
    util-linux
  ];

  systemd.services.rustdesk = {
    description = "RustDesk remote desktop service";
    requires = [ "network-online.target" ];
    after = [
      "systemd-user-sessions.service"
      "network-online.target"
      "display-manager.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "graphical.target" ];
    script = ''
      export PATH=/run/wrappers/bin:$PATH
      ${pkgs.rustdesk-flutter}/bin/rustdesk --service
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    6443
    21115
    21116
    21117
    21118
  ];
  networking.firewall.allowedUDPPorts = [ 21116 ];

  system.stateVersion = "25.11";

  home-manager.users.vbargl = {
    imports = with self.users.vbargl.profiles; [
      minimal
      gui
      vpn
      daily
    ];
    home.stateVersion = "25.11";
  };
}
