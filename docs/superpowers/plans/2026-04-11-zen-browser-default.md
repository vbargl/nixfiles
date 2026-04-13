# Zen Browser as Default Browser — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add zen-browser alongside Firefox and register it as the default browser for all GUI-capable hosts.

**Architecture:** Add zen-browser as a flake input, expose it via the shared overlay (same pattern as nordvpn), then install it and configure xdg-mime associations in `minimal.nix`.

**Tech Stack:** Nix flakes, home-manager, xdg-utils

---

### Task 1: Add zen-browser flake input

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add the input**

In `flake.nix`, inside the `inputs` attrset, add after the `different-error` line:

```nix
zen-browser.url = "github:zen-browser/flake";
```

No `inputs.nixpkgs.follows` — zen-browser manages its own nixpkgs pin. The full inputs block should look like:

```nix
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

  # custom packages
  different-error.url = "github:different-error/nixpkgs/nordvpn";
  zen-browser.url     = "github:zen-browser/flake";
  unstable.url        = "github:nixos/nixpkgs";
};
```

- [ ] **Step 2: Update flake.lock**

```bash
nix flake update zen-browser
```

Expected: `flake.lock` updated with a new `zen-browser` entry. No other inputs change.

- [ ] **Step 3: Verify flake evaluates**

```bash
nix flake show --no-write-lock-file 2>&1 | head -20
```

Expected: output starts with the flake description and lists outputs — no eval errors.

- [ ] **Step 4: Commit**

```bash
git add flake.nix flake.lock
git commit -m "chore: add zen-browser flake input"
```

---

### Task 2: Expose zen-browser via overlay

**Files:**
- Modify: `overlays.nix`

- [ ] **Step 1: Add zen-browser to the overlay**

In `overlays.nix`, inside the overlay body alongside the existing `nordvpn` line, add:

```nix
zen-browser = inputs.zen-browser.packages.${system}.default;
```

The full overlay body should look like:

```nix
overlays.default = final: prev:
  let
    system = final.stdenv.hostPlatform.system;
    config = self.config.nixpkgs;
    unstable = import inputs.unstable { inherit system config; };
  in {
    nordvpn = (import inputs.different-error { inherit system config; }).nordvpn;
    carapace-specs = final.callPackage "${inputs.self}/packages/carapace-specs" {};
    pinchtab = final.callPackage "${inputs.self}/packages/pinchtab" {};
    zen-browser = inputs.zen-browser.packages.${system}.default;
    inherit (unstable) snx-rs nushell rclone;
    deploy-rs = inputs.deploy-rs.packages.${system}.default;
  };
```

- [ ] **Step 2: Verify the overlay evaluates**

```bash
nix eval .#overlays.default --apply 'f: "ok"'
```

Expected: `"ok"` — the overlay expression evaluates without errors.

- [ ] **Step 3: Commit**

```bash
git add overlays.nix
git commit -m "chore: expose zen-browser via overlay"
```

---

### Task 3: Install zen-browser and set as default browser

**Files:**
- Modify: `modules/home-manager/modules/minimal.nix`

- [ ] **Step 1: Add zen-browser to pkgsSet.gui**

In `minimal.nix`, find the `pkgsSet` let binding. Change the `gui` list from:

```nix
gui = [
  ghostty
  walker      # launcher
  firefox     # browser
  thunderbird # email
  peazip      # archive manager
];
```

to:

```nix
gui = [
  ghostty
  walker        # launcher
  firefox       # browser (kept for compatibility)
  zen-browser   # default browser
  thunderbird   # email
  peazip        # archive manager
];
```

- [ ] **Step 2: Add xdg.mimeApps defaults**

At the bottom of `minimal.nix`, before the closing `}`, add the xdg config gated on `hasGuiCapability`:

```nix
xdg.mimeApps = lib.mkIf hasGuiCapability {
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

The final lines of `minimal.nix` should look like:

```nix
  home.packages = lib.mkMerge [
    pkgsSet.cli
    (lib.mkIf hasGuiCapability pkgsSet.gui)
  ];

  xdg.mimeApps = lib.mkIf hasGuiCapability {
    enable = true;
    defaultApplications = {
      "text/html"                = "zen.desktop";
      "x-scheme-handler/http"   = "zen.desktop";
      "x-scheme-handler/https"  = "zen.desktop";
      "x-scheme-handler/about"  = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };
}
```

- [ ] **Step 3: Build the desktop home-manager config to verify**

```bash
nix build .#homeConfigurations.desktop.activationPackage
```

Expected: build succeeds, `result/` symlink created. If zen-browser is unavailable for the system, the error will name the missing package — check the zen-browser flake's supported systems with `nix flake show github:zen-browser/flake`.

- [ ] **Step 4: Confirm mimeapps.list will be generated correctly**

```bash
nix eval .#homeConfigurations.desktop.config.xdg.mimeApps.defaultApplications
```

Expected output:
```
{ "text/html" = "zen.desktop"; "x-scheme-handler/about" = "zen.desktop"; "x-scheme-handler/http" = "zen.desktop"; "x-scheme-handler/https" = "zen.desktop"; "x-scheme-handler/unknown" = "zen.desktop"; }
```

- [ ] **Step 5: Commit**

```bash
git add modules/home-manager/modules/minimal.nix
git commit -m "feat: add zen-browser as default browser"
```
