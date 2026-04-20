{
  flake.lib.capabilities = {
    gui = {
      _type = "gui";
    };
    gpu = {
      _type = "gpu";
    };
    audio = {
      _type = "audio";
    };
    bluetooth = {
      _type = "bluetooth";
    };
    wifi = {
      _type = "wifi";
    };
    zfs = {
      _type = "zfs";
    };
    virtualization = {
      _type = "virtualization";
    };
  };

  flake.lib.hasCapability = cap: caps: builtins.any (c: c._type == cap) caps;

  flake.nixosModules.capabilities =
    { lib, ... }:
    {
      options.nxf.machine.capabilities = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
        description = ''
          Capabilities this machine exposes (picked from `self.lib.capabilities`).
          Modules and stacks inspect this via `self.lib.hasCapability`.
        '';
      };
    };
}
