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
    imports = [
      ./lib
      ./machines
      ./packages
      ./overlays
      ./devshells
    ];

    systems = [ "x86_64-linux" ];

    perSystem = { system, ... }: {
      checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
    };

    flake.nixosModules.default = { lib, config, ... }: {
      imports =
        (lib.attrValues (inputs.nixlite.import ./modules/nixos))
        ++ (lib.attrValues (inputs.nixlite.import ./users));

      options.nxf.profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.deferredModule);
        readOnly = true;
        description = "Profiles exposed by this flake (machines and users).";
      };

      config = {
        nxf.profiles = {
          machines = inputs.nixlite.import ./profiles/machines;
          users    = inputs.nixlite.import ./profiles/users;
        };
        home-manager.sharedModules =
          lib.attrValues (inputs.nixlite.import ./modules/home);
      };
    };
  });
}
