{ lib, config, pkgs, ... }:
let
  cfg = config.modules.nordvpn;
in
{
  options.modules.nordvpn = {
    enable = lib.mkEnableOption "NordVPN service";
  };

  config = lib.mkIf cfg.enable {
    users.groups.nordvpn = { };

    services.resolved.enable = true;

    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.resolve1.set-dns-servers"
              && subject.isInGroup("nordvpn")) {
            return polkit.Result.YES;
          }
        });
      '';
    };
    systemd.services.nordvpnd = {
      description = "NordVPN daemon";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        e2fsprogs
        iproute2
        iptables
        procps
        wireguard-tools
        nordvpn
      ];
      serviceConfig = {
        ExecStart = "${pkgs.nordvpn}/bin/nordvpnd";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "nordvpn";
        RuntimeDirectoryMode = "0750";
        StateDirectory = "nordvpn";
        StateDirectoryMode = "0750";
      };
    };

    systemd.sockets.nordvpnd = {
      description = "NordVPN daemon socket";
      wantedBy = [ "sockets.target" ];
      partOf = [ "nordvpnd.service" ];
      listenStreams = [ "/run/nordvpn/nordvpnd.sock" ];
      socketConfig = {
        DirectoryMode = "0750";
        NoDelay = true;
        SocketGroup = "nordvpn";
        SocketMode = "0770";
      };
    };
  };
}
