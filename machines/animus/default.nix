{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./virtual-hardware-configuration.nix
  ];

  nix.settings.trusted-users = [ "root" "vbargl" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Longhorn v1.11+ requires dm_crypt kernel module
  boot.kernelModules = [ "dm_crypt" ];

  networking.hostName = "animus";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 6443 ];

  users.users.vbargl = {
    isNormalUser = true;
    hashedPassword = null;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" ];
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

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [ "--disable=local-storage" "--disable=traefik" ];
  };

  # Longhorn dependencies
  services.openiscsi = {
    enable = true;
    name = "iqn.2026-03.net.barglvojtech:animus";
  };

  # Longhorn expects iscsiadm at a standard path, not under /nix/store
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
  ];

  environment.systemPackages = with pkgs; [
    vim
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

  system.stateVersion = "25.11";
}
