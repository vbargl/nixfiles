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

  networking.hostName = "ant";
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

  time.timeZone = "Europe/Prague";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.vbargl = {
    isNormalUser = true;
    hashedPassword = null;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFNlZYlDjje/aX9WSd0WyCvEQaqHvbX/5/IWvXkntdu bargl.vojtech.net"
    ];
  };

  security.sudo.extraRules = [{
    users = [ "vbargl" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    git
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.11";
}
