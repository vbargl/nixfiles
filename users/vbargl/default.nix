{ self, inputs, ... }:
{
  flake.users.vbargl = {
    # NixOS-only: system user account, shell, groups, ssh keys.
    nixos =
      { pkgs, ... }:
      {
        users.users.vbargl = {
          isNormalUser = true;
          shell = pkgs.nushell;
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "audio"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzfPQUzXyHZZL1sfHzCA0o5eKdsL+/XrHrVJnAt9liI vbargl@peacock"
          ];
        };
        environment.shells = [ pkgs.nushell ];
      };

    # Personalized sw setups (package + config) and profile bundles.
    # nixlite.import with a raw path returns walkNested keyed by filename.
    packages = inputs.nixlite.import ./packages;
    profiles = inputs.nixlite.import ./profiles;
  };

  # Standalone HM: nh home build .#vbargl
  flake.homeConfigurations.vbargl = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config = self.nixconfig;
      overlays = with self.overlays; [
        pinchtab
        nushell
        rclone
      ];
    };
    extraSpecialArgs = { inherit self inputs; };
    modules = [
      {
        home.username = "vbargl";
        home.homeDirectory = "/home/vbargl";
        home.stateVersion = "25.11";
      }

      ./profiles/minimal.nix
    ];
  };
}
