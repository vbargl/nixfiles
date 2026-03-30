{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.envfs.enable = true;
  services.udisks2.enable = true;
  services.automatic-timezoned.enable = true;
  services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  services.printing.enable = true;
}
