{ self, inputs, ... }:
let
  inherit (inputs) nixpkgs unstable;
  flake = inputs.self;
in
{
  nixpkgs.config = self.config.nixpkgs;

  nix.registry = {
    "vbargl".flake = flake;
    "nixpkgs".flake = nixpkgs;
    "unstable".flake = unstable;
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
