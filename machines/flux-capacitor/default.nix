{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    inputs.agenix.nixosModules.default
  ];

  nix.settings.trusted-users = [ "root" "vbargl" ];

  modules.zerotier = {
    enable = true;
    networkIds = [ "b6079f73c6fe0b88" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Longhorn v1.11+ requires dm_crypt kernel module
  boot.kernelModules = [ "dm_crypt" ];

  networking.hostName = "flux-capacitor";
  networking.networkmanager.enable = true;
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

  age.secrets.wifi-vodafone-psk = {
    file = ../../secrets/wifi-vodafone-psk.age;
  };
  age.secrets.k3s-token = {
    file = ../../secrets/k3s-token.age;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.vbargl = {
    isNormalUser = true;
    hashedPassword = null;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFNlZYlDjje/aX9WSd0WyCvEQaqHvbX/5/IWvXkntdu bargl.vojtech.net"
    ];
  };

  environment.shells = [ pkgs.nushell ];

  security.sudo.extraRules = [{
    users = [ "vbargl" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.vbargl = {
      imports = [ "${inputs.self}/modules/home-manager" ];
      purpose = [ "connectivity" ];
      programs.zellij.enableFishIntegration = false;
      programs.nushell = {
        enable = true;
      };
      home = {
        stateVersion = "25.11";
        username = "vbargl";
        homeDirectory = "/home/vbargl";
        sessionPath = [ "$HOME/.local/bin" ];
      };
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.age.secrets.k3s-token.path;
    extraFlags = [ "--tls-san=172.27.27.9" ];
  };

  # Longhorn dependencies
  services.openiscsi = {
    enable = true;
    name = "iqn.2026-03.net.barglvojtech:flux-capacitor";
  };

  # Longhorn expects iscsiadm at a standard path, not under /nix/store
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
  ];
  environment.systemPackages = with pkgs; [
    vim
    btop
    curl
    git
    nfs-utils
    util-linux
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 6443 ];

  system.stateVersion = "25.11";
}
