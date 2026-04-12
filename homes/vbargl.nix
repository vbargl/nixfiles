{ pkgs, lib, ... }: {
  users.users.vbargl = {
    isNormalUser = true;
    hashedPassword = null;
    shell = lib.mkDefault pkgs.nushell;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzfPQUzXyHZZL1sfHzCA0o5eKdsL+/XrHrVJnAt9liI vbargl@peacock"
    ];
  };

  environment.shells = lib.mkDefault [ pkgs.nushell ];
}
