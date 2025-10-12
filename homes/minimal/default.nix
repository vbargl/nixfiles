{ self, nixpkgs, home-manager, system, ... }@inputs:
{ pkgs, ... }:
{
  nixpkgs.config = import "${self}/common/nixpkgs-config.nix";

  home = {
		stateVersion = "25.05";

		username = "vbargl";
		homeDirectory = "/home/vbargl";

		sessionPath = [
			"$HOME/.local/bin"
		];
  };

	imports = [
		"${self}/common/home-manager/programs/cli/minimal.nix"
		"${self}/common/home-manager/programs/cli/network.nix"
	];
}