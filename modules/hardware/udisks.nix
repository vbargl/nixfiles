{
  flake.nixosModules.udisks = {
    services.udisks2.enable = true;
  };
}
