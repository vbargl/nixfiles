---
title: flake-parts Migration + New Module Structure
date: 2026-04-11
status: approved
---

# flake-parts Migration + New Module Structure

## Overview

Complete restructure of the nixfiles flake from `nix-lite` to `flake-parts`, introducing a new module import syntax, boolean capabilities system, hjem for home file management, and stylix theming with rose-pine.

## Goals

- Replace `lite.modules.eval` with `flake-parts.lib.mkFlake`
- Enable `imports = with self.modules.homeManager; [dev daily]` syntax
- Replace string-based capabilities (`["gui"]`) with boolean attrset (`capabilities.gui = true`)
- Replace standalone home-manager homeConfigurations with hjem integrated into nixosConfigurations
- Add stylix theming with rose-pine scheme

## Architecture

```
flake.nix (flake-parts)
├── config.nix               — nixpkgs config (unchanged)
├── lib/                     — helpers + modules attrset discovery
│   └── modules.nix          — NEW: discoverModules helper
├── homes/
│   ├── vbargl.nix           — user home config (was homes/users/vbargl.nix)
│   └── modules/             — purpose modules (was modules/home-manager/modules/)
│       ├── dev.nix
│       ├── daily.nix
│       └── ...
├── machines/
│   ├── flux-capacitor.nix   — machine config (was machines/flux-capacitor/default.nix)
│   └── modules/             — NixOS modules (was modules/nixos/)
│       ├── options.nix      — NEW: capabilities bool options
│       └── stylix.nix       — NEW: stylix + rose-pine
├── packages/                — custom packages
└── devshells/               — dev shells
```

`modules/` top-level folder is removed. Home and NixOS modules live alongside their configs in `homes/modules/` and `machines/modules/`.

## Section 1: flake.nix

Replace `lite` with `flake-parts`. Each imported file becomes a flake-parts module returning `flake.*` or `perSystem.*` attributes.

```nix
{
  inputs = {
    nixpkgs.url        = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url    = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
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
    localzone = {
      url = "git+ssh://git@github.com/vbargl/localzone";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    different-error.url = "github:different-error/nixpkgs/nordvpn";
    unstable.url        = "github:nixos/nixpkgs";
    # REMOVED: lite
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    imports = [
      ./config.nix
      ./lib
      ./machines
      ./packages
      ./deploy.nix
      ./shell.nix
      ./overlays.nix
      # REMOVED: ./homes (merged into machines)
    ];
  };
}
```

Module shape change — each file now uses flake-parts namespace:

```nix
# Before (lite):
{ self, inputs, lite }: { homeConfigurations = { ... }; }

# After (flake-parts):
{ self, inputs, ... }: { flake.nixosConfigurations = { ... }; }
```

## Section 2: Module Discovery (`lib/modules.nix`)

Auto-discovers all `.nix` files from a directory into an attrset, enabling `with self.modules.homeManager; [dev daily]`.

```nix
{ self, lib, ... }:
let
  discoverModules = dir:
    lib.mapAttrs'
      (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (dir + "/${name}"))
      (lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name)
        (builtins.readDir dir));
in {
  flake.modules = {
    homeManager = discoverModules ../homes/modules;
    nixos       = discoverModules ../machines/modules;
  };
}
```

Adding a new module = create file in `modules/home-manager/modules/` — no manual registration needed.

**Usage in machine config:**

```nix
modules = with self.modules.homeManager; [
  minimal
  dev
  daily
  connectivity
];
```

## Section 3: Capabilities — Boolean Attrset

Replace `listOf (enum [...])` with typed boolean options. Remove `options.purpose` entirely.

Capabilities options move to `machines/modules/options.nix` — NixOS module options (home config is part of nixosSystem via hjem).

```nix
# machines/modules/options.nix
{ lib, config, ... }: {
  options.environment.capabilities = {
    gui = lib.mkEnableOption "graphical environment";
    # future capabilities added here
  };

  # Global helper injected into all modules
  config._module.args.hasCapability = cap:
    config.environment.capabilities.${cap} or false;
}
```

**Before:**
```nix
environment.capabilities = [ "gui" ];
# checked as: builtins.elem "gui" config.environment.capabilities
```

**After:**
```nix
environment.capabilities.gui = true;
# checked as: config.environment.capabilities.gui
# or via helper: hasCapability "gui"
```

**Usage in purpose module:**
```nix
# modules/home-manager/modules/dev.nix
{ lib, pkgs, hasCapability, ... }: {
  home.packages = lib.mkMerge [
    [ git jujutsu ]
    (lib.mkIf (hasCapability "gui") [ vscode code-cursor ])
  ];
}
```

## Section 4: hjem — Home Files via NixOS Module

`homeConfigurations` (standalone) is removed. Home file management moves into `nixosConfigurations` via hjem. Programs previously managed by `programs.*` are configured via raw config files sourced through hjem.

```nix
# machines/flux-capacitor.nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.flux-capacitor = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.hjem.nixosModules.hjem
      inputs.stylix.nixosModules.stylix
      ./hardware-configuration.nix
      {
        environment.capabilities.gui = true;

        hjem.users.vbargl = {
          files = {
            ".config/helix/config.toml".source = ../../config/helix/config.toml;
            ".config/nushell/config.nu".source  = ../../config/nushell/config.nu;
          };
        };
      }
    ] ++ (with self.modules.nixos; [
      stylix
      networking
    ]) ++ (with self.modules.homeManager; [
      minimal
      dev
      daily
      connectivity
    ]);
  };
}
```

**home-manager is fully removed** — not kept as a NixOS module. All purpose modules must be rewritten:
- `home.packages = [...]` → `users.users.vbargl.packages = [...]`
- `programs.X.enable = true` → install package via `users.users.vbargl.packages` + source raw config via `hjem.users.vbargl.files`
- `home.file` → `hjem.users.vbargl.files`

The `self.modules.homeManager` attrset name is kept for clarity but these are now NixOS modules using NixOS options.

## Section 5: Stylix + Rose-Pine

```nix
# machines/modules/stylix.nix
{ inputs, pkgs, ... }: {
  stylix = {
    enable = true;

    base16Scheme = "${inputs.stylix.packages.${pkgs.system}.base16-schemes}/share/themes/rose-pine.yaml";

    image = ../../assets/wallpapers/wallpaper.jpg;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name    = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name    = "Inter";
      };
    };

    cursor = {
      package = pkgs.rose-pine-cursor;
      name    = "BreezeX-RosePine-Linux";
    };
  };
}
```

Included only in machines with GUI capability.

## Migration Notes

- `lib/functions/mkHome.nix` — remove (replaced by hjem + nixosSystem)
- `lib/functions/mkHost.nix` — adapt to flake-parts (return `flake.nixosConfigurations`)
- `homes/` directory — remove after migrating users into machines
- `modules/home-manager/options.nix` — move to `machines/modules/options.nix`, remove `options.purpose`
- `modules/nixos/` → move to `machines/modules/`
- `modules/home-manager/modules/` → move to `homes/modules/`
- `homes/users/vbargl.nix` → `homes/vbargl.nix`
- `machines/flux-capacitor/default.nix` → `machines/flux-capacitor.nix`
- All purpose modules: remove `builtins.elem "X" config.purpose` checks, replace with `hasCapability` or direct bool access
- All purpose modules: replace `home.packages` with `users.users.vbargl.packages`, replace `programs.*` with raw configs + hjem
- `home-manager` input — remove from flake.nix entirely

## What Does NOT Change

- Internal content of purpose modules (`homes/modules/*.nix` — just moved)
- Package sets within each purpose module (dev.nix, daily.nix, etc.)
- `assets/`, `secrets/`, `kubernetes/` directories
- deploy-rs configuration shape
