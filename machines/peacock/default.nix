{ self, inputs, ... }: {
  flake.nixosConfigurations.peacock = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.hjem.nixosModules.hjem
      inputs.stylix.nixosModules.stylix

      ./config.nix
      ../../users/vbargl

    ] ++ (with self.modules.machines; [
      options
      zerotier
      nordvpn
      localzone
      snx-rs
      wine
      snd_hda_intel
    ]) ++ (with self.profiles.machines; [
      minimal
      stylix
    ]) ++ (with self.profiles.users; [
      minimal
      dev
      daily
      connectivity
      media
      games
      cluster-management
    ]) ++ (with self.modules.users; [
      caelestia
      helix
    ]) ++ [({ config, pkgs, lib, ... }: {
      nixpkgs.config = { allowUnfree = true; allowUnfreePredicate = _: true; };
      nixpkgs.overlays = [ self.overlays.default ];

      environment.capabilities.gui = true;
      environment.capabilities.dev = true;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "root" "vbargl" ];
      };

      nxf.nixos.zerotier = {
        enable = true;
        networkIds = [ "b6079f73c6fe0b88" ];
      };
      nxf.nixos.snx-rs.enable = true;
      nxf.nixos.nordvpn.enable = true;
      nxf.nixos.localzone.enable = true;
      nxf.nixos.wine.enable = true;

      nxf.home.caelestia = {
        enable = true;
        settings = {
          services.useFahrenheit      = lib.mkDefault false;
          services.useTwelveHourClock = lib.mkDefault false;
          bar.status.showAudio        = lib.mkDefault true;
          general.apps.explorer       = lib.mkDefault [ "dolphin" ];
          general.apps.terminal       = lib.mkDefault [ "ghostty" ];
          paths.wallpaperDir          = lib.mkDefault "${self}/assets/wallpapers";
        };
      };

      users.users.vbargl.extraGroups = [ "input" "libvirtd" "docker" "nordvpn" config.nxf.nixos.localzone.group ];

      hjem.users.vbargl.directory = "/home/vbargl";

      system.stateVersion = "25.05";
    })];
  };
}
