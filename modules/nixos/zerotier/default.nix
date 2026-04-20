{ lib, config, ... }:
let
  cfg = config.nxf.nixos.zerotier;
in
{
  options.nxf.nixos.zerotier = {
    enable = lib.mkEnableOption "ZeroTier VPN";
    networkIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "ZeroTier network IDs to join";
    };
  };

  config = lib.mkIf cfg.enable {
    services.zerotierone = {
      enable = true;
      joinNetworks = cfg.networkIds;
    };

    networking.firewall.trustedInterfaces = [ "zt+" ];
  };
}
