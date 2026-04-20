{
  description = ''
    Nix flake for managing NixOS configurations.
    Uses flake-parts for modular output composition.
    Machines include home management via home-manager.
    Options live under the `nxf.*` namespace.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ self, lib, ... }: {
    imports = lib.flatten [
      ./lib
      ./machines
      ./packages
      ./overlays
      ./devshells
      (inputs.nixlite.import { path = [ ./stacks ./modules/nixos ]; flatten = true; })
    ];

    systems = [ "x86_64-linux" ];

    perSystem = { system, ... }: {
      checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
    };

    # Transitional shim (Task 4 → Task 6). Keeps `nxf.profiles` alive, pulls in
    # ./users (NixOS module) and home-manager.sharedModules so machines can keep
    # using `nxf.users.vbargl.profiles = with config.nxf.profiles.users; [ … ];`
    # until Tasks 5 and 6 migrate home and user wiring. REMOVE in Task 6.
    flake.nixosModules.profiles-shim = { lib, ... }: {
      imports = inputs.nixlite.import { path = [ ./users ]; flatten = true; };

      options.nxf.profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.deferredModule);
        readOnly = true;
        description = "TRANSITIONAL: profiles registry; removed in Task 6.";
      };

      config.nxf.profiles = {
        machines = inputs.nixlite.import ./profiles/machines;
        users    = inputs.nixlite.import ./profiles/users;
      };

      # Home-manager sharedModules wiring is retained here transitionally; Task 5
      # rewraps home modules and this moves into their emitters.
      config.home-manager.sharedModules = inputs.nixlite.import {
        path = [ ./modules/home ];
        flatten = true;
      };
    };
  });
}
