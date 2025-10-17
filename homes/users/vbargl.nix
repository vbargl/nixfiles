{ self, ... }:
{
  nixpkgs.config = self.config.nixpkgs;

  home = {
    stateVersion = "25.05";

    username = "vbargl";
    homeDirectory = "/home/vbargl";

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };
}
