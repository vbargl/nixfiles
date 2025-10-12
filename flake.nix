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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/age-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.home-manager.flakeModules.home-manager # does support flake-parts

        ./lib
        ./homes
        ./overlays
      ];
    };
}
