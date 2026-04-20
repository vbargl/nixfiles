{
  description = ''
    Nix flake for managing NixOS configurations.
    Uses flake-parts for modular output composition.
    Machines include home management via hjem.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic = {
      # no nixpkgs.follows: chaotic's binary cache is keyed by their own nixpkgs pin.
      # Overriding with `follows` changes derivation hashes → cache misses on kernel/nvidia.
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };

    localzone = {
      url = "git+ssh://git@github.com/vbargl/localzone";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    different-error = {
      url = "github:different-error/nixpkgs/nordvpn";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    unstable = {
      url = "github:nixos/nixpkgs";
    };

    nixlite.url = "github:vbargl/nixlite";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    imports = [
      ./lib
      ./nxf-modules.nix
      ./machines
      ./packages
      ./deploy.nix
      ./shell.nix
      ./overlays.nix
    ];
  };
}
