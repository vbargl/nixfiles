{
  flake.stacks.host =
    { self, inputs, ... }:
    {
      nixpkgs.config = self.nixconfig;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "vbargl"
        ];
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs self; };
    };
}
