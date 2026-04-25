{
  flake.nixosModules.power = {
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    services.thermald.enable = true;
  };
}
