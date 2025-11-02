{ self, ... }:
{
  nixpkgs.config = self.config.nixpkgs;

  nix.registry = {
    "vbargl".to = {
      type = "github";
      owner = "vbargl";
      repo = "nixfiles";
    };
    "nixpkgs".to = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
    };
    "unstable".to = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
    };
  };

  home = {
    stateVersion = "25.05";

    username = "vbargl";
    homeDirectory = "/home/vbargl";

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };
}
