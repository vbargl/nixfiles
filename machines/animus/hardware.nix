# Minimal hardware config for VM; build-vm overrides this at runtime
{ pkgs, ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Longhorn storage disks — format on first boot if no filesystem exists
  # /dev/vdb → /var/lib/longhorn/nvme (fast storage, 500GB qcow2)
  # /dev/vdc → /var/lib/longhorn/hdd  (bulk storage, 2TiB qcow2)
  systemd.services =
    let
      mkFormatService =
        {
          device,
          label,
          mountUnit,
        }:
        {
          description = "Format ${device} with ext4 if unformatted";
          wantedBy = [ "multi-user.target" ];
          before = [ "${mountUnit}.mount" ];
          unitConfig = {
            ConditionPathExists = device;
            DefaultDependencies = false;
          };
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "format-${label}" ''
              if ! ${pkgs.util-linux}/bin/blkid -p ${device}; then
                ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L ${label} ${device}
              fi
            '';
          };
        };
    in
    {
      "format-longhorn-nvme" = mkFormatService {
        device = "/dev/vdb";
        label = "longhorn-nvme";
        mountUnit = "var-lib-longhorn-nvme";
      };
      "format-longhorn-hdd" = mkFormatService {
        device = "/dev/vdc";
        label = "longhorn-hdd";
        mountUnit = "var-lib-longhorn-hdd";
      };
    };

  fileSystems."/var/lib/longhorn/nvme" = {
    device = "/dev/vdb";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/var/lib/longhorn/hdd" = {
    device = "/dev/vdc";
    fsType = "ext4";
    options = [ "nofail" ];
  };
}
