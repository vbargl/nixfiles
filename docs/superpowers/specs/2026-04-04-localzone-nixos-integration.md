# localzone NixOS Integration

**Date:** 2026-04-04
**Status:** Final

## Goal

Integrate localzone (local DNS resolver daemon) into nixfiles as a flake input, NixOS module, and enable it on peacock.

## Components

### 1. Flake Input

Add `localzone` as a flake input in `flake.nix`:
```nix
inputs.localzone.url = "github:vbargl/localzone";
```

Pass it through to modules via the existing module system.

### 2. NixOS Module (`modules/nixos/services/localzone/default.nix`)

Follows existing module pattern (zerotier, nordvpn, snx-rs).

**Options:**
- `modules.localzone.enable` — mkEnableOption
- `modules.localzone.watchDirs` — list of directories to watch for TOML zone files (default: `["/etc/localzone/zones"]`)
- `modules.localzone.settings` — daemon config overrides (listen, interface, interface_ip, socket)

**Exposed values (not options, computed):**
- `modules.localzone.group` — string, the localzone group name (`"localzone"`)
- `modules.localzone.dirForUser` — function: `user -> "/home/${user}/.config/localzone"`

**Config:**
- `users.groups.localzone = {}` — create the group
- Systemd service:
  - `ExecStart = "${pkg}/bin/localzone daemon"`
  - `AmbientCapabilities = CAP_NET_ADMIN CAP_NET_BIND_SERVICE`
  - `CapabilityBoundingSet = CAP_NET_ADMIN CAP_NET_BIND_SERVICE`
  - `DynamicUser = false` (needs access to user dirs)
  - `User = root` (needs CAP_NET_ADMIN for interface creation + access to all watch dirs)
  - `Group = localzone`
  - `Restart = on-failure`
  - `After = network.target dbus.service systemd-resolved.service`
  - `Wants = systemd-resolved.service`
- Generate `/etc/localzone/config.toml` from options
- tmpfiles rules for system watchDirs (skip /home/ paths)

### 3. Peacock Configuration

```nix
modules.localzone = {
  enable = true;
  watchDirs = [
    "/etc/localzone/zones"
    (config.modules.localzone.dirForUser "vbargl")
  ];
};

users.users.vbargl.extraGroups = [ config.modules.localzone.group ];
```

## File Changes

| File | Action |
|------|--------|
| `flake.nix` | Add localzone input, pass to modules |
| `modules/nixos/services/localzone/default.nix` | New module |
| `machines/peacock/default.nix` | Enable localzone, add group to user |

## Testing

- `nix flake check` passes
- `nixos-rebuild build` succeeds
- After switch: `systemctl status localzone`, `localzone status`, `dig @127.0.0.2 <test-record>`
