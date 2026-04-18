{ lib, config, ... }: {
  options.environment.capabilities = {
    gui = lib.mkEnableOption "graphical environment (display server, GUI apps)";
    dev = lib.mkEnableOption "development tooling (compilers, language servers)";
  };

  # Compatibility stub: stylix's gnome module references this option which was
  # removed in nixos-25.11. Provide a no-op definition so evaluation succeeds.
  options.services.displayManager.generic = lib.mkOption {
    default = {};
    type = lib.types.anything;
    description = "Compatibility stub for stylix/gnome (removed in nixos-25.11)";
  };

  config._module.args.hasCapability = cap:
    config.environment.capabilities.${cap} or false;
}
