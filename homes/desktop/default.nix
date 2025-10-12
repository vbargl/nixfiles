{ self, nixpkgs, ... }@inputs: # home-manager module
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
		"${self}/common/home-manager/programs/cli/dev.nix"
		"${self}/common/home-manager/programs/cli/network.nix"

		"${self}/common/home-manager/programs/gui/minimal.nix"
		"${self}/common/home-manager/programs/gui/daily.nix"
		"${self}/common/home-manager/programs/gui/dev.nix"
		"${self}/common/home-manager/programs/gui/games.nix"
		"${self}/common/home-manager/programs/gui/media.nix"
	];
}
