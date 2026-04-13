# Wine Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Wine support for running Windows dev tools, activated under `dev` purpose + `gui` capability, with a companion NixOS system module for 32-bit GPU support.

**Architecture:** Two new files: a home-manager module (`wine.nix`) that adds Bottles, Wine, and Winetricks when `dev`+`gui` are active, and a NixOS services module that enables `hardware.graphics.enable32Bit`. The NixOS module must be wired into `mkHost` (like nordvpn, zerotier) and enabled on `peacock`.

**Tech Stack:** Nix/NixOS 25.11, home-manager, `wineWowPackages.waylandFull`, `bottles`, `winetricks`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `modules/home-manager/modules/wine.nix` | Wine packages for dev+gui users |
| Modify | `modules/home-manager/default.nix` | Import wine.nix |
| Create | `modules/nixos/services/wine/default.nix` | NixOS module: 32-bit GPU support |
| Modify | `lib/functions/mkHost.nix` | Include wine service module in all hosts |
| Modify | `machines/peacock/default.nix` | Enable `modules.wine.enable = true` |

---

### Task 1: Create the home-manager Wine module

**Files:**
- Create: `modules/home-manager/modules/wine.nix`

NixOS modules have no traditional unit tests — verification is a successful `nix build`.

- [ ] **Step 1: Create `modules/home-manager/modules/wine.nix`**

```nix
{ lib, pkgs, config, ... }:
let
  hasDevPurpose    = builtins.elem "dev" config.purpose;
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;

  pkgsSet = with pkgs; [
    wineWowPackages.waylandFull # Wine with native Wayland + 32/64-bit support
    bottles                     # GTK4 GUI manager, isolated prefixes per app
    winetricks                  # CLI installer for Windows components (.NET, VCR, etc.)
  ];
in
{
  config = lib.mkIf (hasDevPurpose && hasGuiCapability) {
    home.packages = pkgsSet;
  };
}
```

- [ ] **Step 2: Import in `modules/home-manager/default.nix`**

Add `./modules/wine.nix` to the imports list:

```nix
{
  imports = [
    ./options.nix

    ./modules/carapace-specs.nix
    ./modules/helix.nix
    ./modules/minimal.nix
    ./modules/daily.nix
    ./modules/dev.nix
    ./modules/connectivity.nix
    ./modules/caelestia.nix
    ./modules/cluster-management.nix
    ./modules/media.nix
    ./modules/games.nix
    ./modules/wine.nix
  ];
}
```

- [ ] **Step 3: Verify syntax**

```bash
cd /home/vbargl/personal/nixfiles
nix flake check --no-build 2>&1 | head -30
```

Expected: no errors (warnings about `--no-build` are fine)

- [ ] **Step 4: Commit**

```bash
git add modules/home-manager/modules/wine.nix modules/home-manager/default.nix
git commit -m "feat(home-manager): add wine module under dev purpose"
```

---

### Task 2: Create the NixOS Wine service module

**Files:**
- Create: `modules/nixos/services/wine/default.nix`
- Modify: `lib/functions/mkHost.nix`
- Modify: `machines/peacock/default.nix`

- [ ] **Step 1: Create `modules/nixos/services/wine/default.nix`**

```nix
{ lib, config, ... }:
let
  cfg = config.modules.wine;
in
{
  options.modules.wine = {
    enable = lib.mkEnableOption "Wine 32-bit GPU support";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable32Bit = true;
  };
}
```

- [ ] **Step 2: Add wine module to `lib/functions/mkHost.nix`**

Add `"${flake}/modules/nixos/services/wine"` to the modules list:

```nix
{ self, inputs, ... }:
let
  flake = inputs.self;
  inherit (inputs) nixpkgs disko home-manager;
in
{
  lib.mkHost = system: hostPath:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        "${flake}/modules/nixos/minimal.nix"
        "${flake}/modules/nixos/services/zerotier"
        "${flake}/modules/nixos/services/snx-rs"
        "${flake}/modules/nixos/services/nordvpn"
        "${flake}/modules/nixos/services/localzone"
        "${flake}/modules/nixos/services/wine"
        hostPath
        {
          nixpkgs.config = self.config.nixpkgs;
          nixpkgs.overlays = [ self.overlays.default ];
          home-manager.extraSpecialArgs = { inherit inputs; self = inputs.self; };
        }
      ];
    };
}
```

- [ ] **Step 3: Enable Wine on `machines/peacock/default.nix`**

Add `modules.wine.enable = true;` near the other module enables (around line 20–26):

```nix
  # VPN services
  modules.zerotier = {
    enable = true;
    networkIds = [ "b6079f73c6fe0b88" ];
  };
  modules.snx-rs.enable = true;
  modules.nordvpn.enable = true;
  modules.localzone.enable = true;
  modules.wine.enable = true;
```

- [ ] **Step 4: Build peacock config to verify**

```bash
cd /home/vbargl/personal/nixfiles
nix build .#nixosConfigurations.peacock.config.system.build.toplevel --no-link 2>&1 | tail -20
```

Expected: build completes without errors

- [ ] **Step 5: Commit**

```bash
git add modules/nixos/services/wine/default.nix lib/functions/mkHost.nix machines/peacock/default.nix
git commit -m "feat(nixos): add wine module with 32-bit GPU support, enable on peacock"
```
