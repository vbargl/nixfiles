{
  flake.stacks.host = { self, inputs, ... }: {
    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
    nixpkgs.overlays = [ self.overlays.default ];

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "vbargl" ];
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit inputs self; };
  };
}
