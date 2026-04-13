# Zen Browser as Default Browser

**Date:** 2026-04-11
**Status:** Approved

## Goal

Add zen-browser alongside Firefox and set it as the system default browser for all GUI-capable hosts, using the official `zen-browser/flake` as the package source.

## Scope

Three files changed — no new modules, no changes to machine configs or `mkHome.nix`.

## Changes

### `flake.nix` — new input

```nix
zen-browser.url = "github:zen-browser/flake";
```

No `nixpkgs.follows` — zen-browser manages its own nixpkgs pin.

### `overlays.nix` — expose as `pkgs.zen-browser`

```nix
zen-browser = inputs.zen-browser.packages.${system}.default;
```

Follows the existing `nordvpn` pattern: a custom flake input exposed via the shared overlay so all modules can consume it as a plain `pkgs.*` attribute.

### `minimal.nix` — package + xdg defaults

1. Add `zen-browser` to `pkgsSet.gui` alongside `firefox` (both remain installed).
2. Add `xdg.mimeApps` block inside the `lib.mkIf hasGuiCapability` guard:

```nix
xdg.mimeApps = {
  enable = true;
  defaultApplications = {
    "text/html"                = "zen.desktop";
    "x-scheme-handler/http"   = "zen.desktop";
    "x-scheme-handler/https"  = "zen.desktop";
    "x-scheme-handler/about"  = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";
  };
};
```

Firefox stays installed but is no longer the registered default. KDE Plasma picks up the xdg-mime associations automatically.

## Non-goals

- Removing Firefox
- Machine-specific browser config
- Browser profile or extension management
