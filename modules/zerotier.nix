{
  flake.nixosModules.zerotier =
    { lib, config, ... }:
    {
      options.nxf.nixos.zerotier.networkIds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "ZeroTier network IDs to join";
      };

      config = {
        services.zerotierone = {
          enable = true;
          joinNetworks = config.nxf.nixos.zerotier.networkIds;
        };

        networking.firewall.trustedInterfaces = [ "zt+" ];
      };
    };
}
