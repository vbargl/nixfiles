{ lib, config, pkgs, ... }:
let
  cfg = config.modules.snx-rs;
in
{
  options.modules.snx-rs = {
    enable = lib.mkEnableOption "snx-rs VPN client service";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.snx-rs = {
      description = "snx-rs Check Point VPN client";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ iproute2 kmod ];
      serviceConfig = {
        ExecStart = "${pkgs.snx-rs}/bin/snx-rs -m command";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
