{
  flake.nixosModules.wifi = {
    networking.networkmanager.enable = true;
    services.resolved.enable = true;
  };
}
