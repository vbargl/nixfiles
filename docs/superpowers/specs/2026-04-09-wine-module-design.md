# Wine Module Design

**Date:** 2026-04-09  
**Status:** Approved

## Summary

Add Wine support for running Windows dev tools from third-party contractors. Two files: a home-manager module for packages and a NixOS system module for 32-bit GPU support.

## Home-manager module

**File:** `modules/home-manager/modules/wine.nix`

- Activates when `purpose` contains `"dev"` AND `environment.capabilities` contains `"gui"`
- Packages:
  - `wineWowPackages.waylandFull` — Wine with native Wayland support, 32+64-bit (WoW64)
  - `bottles` — GTK4 GUI manager, Wayland-native, isolated per-app Wine prefixes, built-in dependency installer (.NET, Visual C++ runtimes, etc.)
  - `winetricks` — CLI tool for installing Windows components into Wine prefixes
- Imported in `modules/home-manager/default.nix`
- No new `purpose` value needed; reuses existing `"dev"` purpose

## NixOS system module

**File:** `modules/nixos/programs/wine.nix`

- Exposes `programs.wine.enable` option (bool, default `false`)
- When enabled: sets `hardware.graphics.enable32Bit = true`
- Required for 32-bit Windows executables to use OpenGL/GPU acceleration
- Follows the existing pattern in `modules/nixos/programs/` (nordvpn, zerotier, etc.)
- Machine configs opt in by importing the module and setting `programs.wine.enable = true`

## Out of scope

- No new `purpose` value — Wine is a dev tool, not a separate purpose
- No per-machine Wine prefix configuration (managed by Bottles at runtime)
