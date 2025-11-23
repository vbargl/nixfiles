{ self, inputs, ... }:
{
  nixpkgs.config = self.config.nixpkgs;

  home.activation.setupNixRegistry = ''
    nix registry add nixpkgs github:nixos/nixpkgs/${inputs.unstable.rev}
    nix registry add nixos github:nixos/nixpkgs/${inputs.nixpkgs.rev}
  '';

  home = {
    stateVersion = "25.05";

    username = "vbargl";
    homeDirectory = "/home/vbargl";

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };
}
