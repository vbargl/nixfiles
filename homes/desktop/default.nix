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

	programs = {
		fish.enable = true;

		helix = {
			enable = true;
			defaultEditor = true;
		};

		zellij = {
			enable = true;
			enableFishIntegration = true;
		};

		# enable with update to 25.11
		# jjui = {
		#   enable = true;
		# };

		direnv = {
			enable = true;
			nix-direnv.enable = true;
		};
	};

	home.packages = with pkgs; [
		jujutsu
		git
		lazygit
		nixd

		moreutils
		nmap
		curl
		lf
		fzf
		rclone
		dasel
		bat
		htop
		gtrash
		zip
		unzip
		fd
		bc
		less

		zerotierone
		snx-rs
		# nordvpn (when added)
		
		keepassxc # password manager 
		winbox4   # microtik manager
		rustdesk  # remote desktop manager 
		
		vscode
		jetbrains.idea-ultimate
		jetbrains.idea-community
		postman
		realvnc-vnc-viewer
		remmina
		google-chrome
		p11-kit
		
		steam     # gaming platform
		moonlight # streaming service for games
		
		vlc # robust media player
		mpv # simple media player
		feh # simple photo viewer
		
		walker      # launcher
		firefox     # browser
		thunderbird # email
		peazip      # archive manager
		waybar		  # status bar
		mako		    # notification daemon
		spotify		  # music streaming
	];
}
