{ inputs, ... }:
{
  flake.nixosModules.localzone =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.nxf.nixos.localzone;
      pkg = inputs.localzone.packages.${pkgs.system}.default;
    in
    {
      options.nxf.nixos.localzone.group = lib.mkOption {
        type = lib.types.str;
        default = "localzone";
        readOnly = true;
        description = "Group name for localzone socket access";
      };

      config = {
        users.groups.${cfg.group} = { };

        environment.systemPackages = [ pkg ];

        systemd.services.localzone = {
          description = "localzone local DNS resolver";
          after = [
            "network.target"
            "dbus.service"
            "systemd-resolved.service"
          ];
          wants = [ "systemd-resolved.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkg}/bin/localzone daemon";
            Restart = "on-failure";
            RestartSec = 5;
            RuntimeDirectory = "localzone";
            RuntimeDirectoryMode = "0750";
            AmbientCapabilities = [
              "CAP_NET_ADMIN"
              "CAP_NET_BIND_SERVICE"
            ];
            CapabilityBoundingSet = [
              "CAP_NET_ADMIN"
              "CAP_NET_BIND_SERVICE"
            ];
            Group = cfg.group;
          };
        };
      };
    };
}
