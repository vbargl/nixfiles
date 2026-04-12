{ lib, config, ... }: {
  options.environment.capabilities = {
    gui = lib.mkEnableOption "graphical environment (display server, GUI apps)";
  };

  config._module.args.hasCapability = cap:
    config.environment.capabilities.${cap} or false;
}
