{
  description = ''
    Nix flake for managing NixOS configurations and Home Manager setups.

    This flake includes:
    - NixOS configuration for the host "peacock"
      - With special subfolder _modules which contains reusable modules for nixos
    - Home Manager configuration for the user "vbargl"
      - With special subfolder _modules which contains reusable modules for home-manager
    - DevShells for my development environments
  '';
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    lite.url = "github:vbargl/nix-lite/v1.0.0";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/age-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # custom packages
    different-error.url = "github:different-error/nixpkgs/nordvpn";
    unstable.url        = "github:nixos/nixpkgs";
  };

  outputs = { lite, ... }@inputs:
    lite.modules.eval inputs [
      ./config.nix
      ./lib
      ./homes
      ./packages
    ];
}
