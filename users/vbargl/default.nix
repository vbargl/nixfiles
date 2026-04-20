{ config, lib, pkgs, ... }:
let cfg = config.nxf.users.vbargl;
in {
  options.nxf.users.vbargl = {
    enable = lib.mkEnableOption "vbargl system user";
    profiles = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      description = "home-manager profile modules applied to vbargl.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.vbargl = {
      isNormalUser = true;
      shell = pkgs.nushell;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzfPQUzXyHZZL1sfHzCA0o5eKdsL+/XrHrVJnAt9liI vbargl@peacock"
      ];
    };

    environment.shells = [ pkgs.nushell ];

    home-manager.users.vbargl = {
      home.stateVersion = "25.11";
      home.username = "vbargl";
      home.homeDirectory = "/home/vbargl";
      imports = cfg.profiles;
    };
  };
}
