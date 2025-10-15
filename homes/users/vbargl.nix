{ self, ... }:
{
  nixpkgs.config = import "${self}/nixpkgs/config.nix";

  home = {
    stateVersion = "25.05";

    username = "vbargl";
    homeDirectory = "/home/vbargl";

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };
}
