# nixlite Adoption — Replace `discoverModules`

**Date:** 2026-04-17
**Status:** Approved (brainstorming phase)
**Scope:** Replace the local `discoverModules` helper in `lib/default.nix` with `nixlite.import` from `github:vbargl/nixlite`.

## Motivation

`lib/default.nix` currently defines a minimal `discoverModules` that builds `flake.modules.{homeManager,nixos}` from the filesystem. It handles only two cases:

- `foo.nix` → `{ foo = ./foo.nix; }`
- `dir/` → `{ dir = ./dir; }` (assumes `dir/default.nix` exists)

The second case silently breaks if a subdirectory lacks `default.nix`. The desired extension is recursive walking: a directory without `default.nix` becomes a nested attrset mirroring its file tree, enabling organization by feature without a `default.nix` in every directory.

`nixlite.import` (owned by the same user, published at `github:vbargl/nixlite`) implements this exact semantic plus a `resolve` escape hatch for passing context to leaf functions. Adopting it avoids duplicating and maintaining the same logic in-tree.

## Semantics of `nixlite.import`

Identical to the design we specified, so we adopt it verbatim:

| Filesystem shape | Attrset entry |
|---|---|
| `foo.nix` | `foo = import ./foo.nix` |
| `dir/default.nix` present | `dir = import ./dir` (siblings ignored) |
| `dir/` without `default.nix` | `dir = <recursed attrset>` |
| non-`.nix` file | ignored |
| root `default.nix` | not emitted as a key |

Values are **imported** (not paths). For NixOS module files this means a function `{lib, config, pkgs, ...}: { ... }` — the module system accepts both paths and functions, so depth-1 consumers continue to work unchanged.

Signature: `nixlite.import : (Path | { path : Path; resolve? : Any }) -> AttrSet`.

## Changes

### `flake.nix`

Add a new input:

```nix
inputs.nixlite.url = "github:vbargl/nixlite";
```

No `inputs.nixpkgs.follows` override. `nixlite` only references `nixpkgs` for its own `checks` output, not for the library itself, so following adds no value.

### `lib/default.nix`

Rewrite to delegate to `nixlite.import`:

```nix
{ inputs, ... }:
{
  flake.modules = {
    homeManager = inputs.nixlite.import ../homes/modules;
    nixos       = inputs.nixlite.import ../machines/modules;
  };
}
```

The local `discoverModules` definition is deleted. The file still registers the same `flake.modules.*` outputs with the same depth-1 keys, so existing consumers are unaffected.

### Consumers

No changes required. Grep confirms only `machines/flux-capacitor.nix` and `machines/peacock.nix` read `self.modules.*`, and both access depth-1 entries that resolve to valid NixOS modules (either functions from `.nix` files, or functions from a directory's `default.nix`).

## Behavioral differences vs. the old `discoverModules`

1. **Leaf type:** paths → imported values (functions for modules; attrsets for plain data files). Transparent to the module system.
2. **Subdirectory without `default.nix`:** previously emitted a broken path; now produces a nested attrset. This is the desired new behavior.
3. **Non-`.nix` files in a module directory:** previously hidden from the attrset (same); still hidden.
4. **Root `default.nix`:** previously excluded as a key (same); still excluded.

## What stays out of scope

- **Local wrapper around `nixlite.import`.** No value until there's a second caller needing different defaults.
- **Renaming `flake.modules.homeManager`.** The misnomer (these are NixOS modules) predates this change and is noted in the prior flake-parts migration spec. Out of scope.
- **Restructuring `homes/modules/` or `machines/modules/`.** No directory is split in this change.
- **Adopting `nixlite.merge` / `mergeAll`.** Available for future use, not introduced here.
- **Migrating to true hjem user modules.** Tracked separately; see "Follow-ups" below.
- **Running `nix flake check` or any rebuild.** Verification is the user's responsibility per standing rules.

## Verification

After applying the change, the user will run:

```sh
nix flake check
nix build .#nixosConfigurations.peacock.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.flux-capacitor.config.system.build.toplevel --dry-run
```

Success criteria: both machines evaluate without error and `flake.modules.{homeManager,nixos}` exposes the same depth-1 keys as before.

## Follow-ups

- **hjem migration.** Rewrite `homes/modules/*.nix` as hjem user modules (class `hjem`, consumed via `hjem.users.vbargl.imports`). Requires splitting NixOS-level options (`users.users.*.packages`, `programs.*`) out of each module and wiring `hasCapability` through `hjem.specialArgs`. Separate brainstorming session.
