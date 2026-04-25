{
  flake.nixosModules.nix =
    { self, inputs, ... }:
    {
      nixpkgs.config = self.nixconfig;

      nix.registry = {
        vbargl.flake = self;
        nixpkgs.flake = inputs.nixpkgs;
        unstable.flake = inputs.unstable;
      };

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "vbargl"
        ];
        substituters = [
          "https://chaotic-nyx.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
}
