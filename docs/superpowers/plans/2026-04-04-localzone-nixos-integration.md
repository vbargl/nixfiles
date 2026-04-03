# localzone NixOS Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add localzone daemon as a flake input, NixOS module, and enable it on peacock.

**Architecture:** localzone is an external Go project at `github:vbargl/localzone` with its own `flake.nix` that exports a package. nixfiles imports it as a flake input, provides a NixOS service module following the existing `modules.<name>` pattern, and enables it on the peacock machine.

**Tech Stack:** Nix flakes, NixOS module system, systemd

---

### Task 1: Add localzone flake input

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add localzone to flake inputs**

In `flake.nix`, add to the `inputs` block after the `caelestia-shell` input:

```nix
    localzone = {
      url = "github:vbargl/localzone";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

- [ ] **Step 2: Verify flake lock resolves**

Run:
```bash
nix flake lock --update-input localzone
```

Expected: `flake.lock` updates with localzone entry, no errors.

- [ ] **Step 3: Commit**

```bash
git add flake.nix flake.lock
git commit -m "chore: add localzone flake input"
```

---

### Task 2: Create localzone NixOS module

**Files:**
- Create: `modules/nixos/services/localzone/default.nix`

- [ ] **Step 1: Create the module file**

Create `modules/nixos/services/localzone/default.nix`:

```nix
{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.modules.localzone;
  pkg = inputs.localzone.packages.${pkgs.system}.default;

  configFile = pkgs.writeText "localzone-config.toml" ''
    listen = "${cfg.settings.listen}"
    interface = "${cfg.settings.interface}"
    interface_ip = "${cfg.settings.interfaceIp}"
    socket = "${cfg.settings.socket}"

    watch_dirs = [
    ${lib.concatMapStringsSep "\n" (d: "  \"${d}\",") cfg.watchDirs}
    ]
  '';
in
{
  options.modules.localzone = {
    enable = lib.mkEnableOption "localzone local DNS resolver";

    group = lib.mkOption {
      type = lib.types.str;
      default = "localzone";
      readOnly = true;
      description = "Group name for localzone socket access";
    };

    dirForUser = lib.mkOption {
      type = lib.types.unspecified;
      default = user: "/home/${user}/.config/localzone";
      readOnly = true;
      description = "Function: user -> path to user's localzone config dir";
    };

    watchDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/etc/localzone/zones" ];
      description = "Directories to watch for TOML zone files";
    };

    settings = {
      listen = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.2:53";
        description = "Address for DNS server to listen on";
      };
      interface = lib.mkOption {
        type = lib.types.str;
        default = "localzone0";
        description = "Dummy network interface name";
      };
      interfaceIp = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.2";
        description = "IP address for the dummy interface";
      };
      socket = lib.mkOption {
        type = lib.types.str;
        default = "/run/localzone/localzone.sock";
        description = "Path to the control socket";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = {};

    environment.systemPackages = [ pkg ];

    systemd.services.localzone = {
      description = "localzone local DNS resolver";
      after = [ "network.target" "dbus.service" "systemd-resolved.service" ];
      wants = [ "systemd-resolved.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkg}/bin/localzone daemon --config ${configFile}";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "localzone";
        RuntimeDirectoryMode = "0750";
        AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
        Group = cfg.group;
      };
    };

    systemd.tmpfiles.rules =
      builtins.filter (r: r != null)
        (map (dir:
          if lib.hasPrefix "/home/" dir then null
          else "d ${dir} 0755 root ${cfg.group} -"
        ) cfg.watchDirs);
  };
}
```

- [ ] **Step 2: Verify file exists and syntax looks right**

Run:
```bash
cat modules/nixos/services/localzone/default.nix | head -5
```

Expected: Shows the first 5 lines of the module.

- [ ] **Step 3: Commit**

```bash
git add modules/nixos/services/localzone/default.nix
git commit -m "feat: add localzone NixOS module"
```

---

### Task 3: Register module in mkHost

**Files:**
- Modify: `lib/functions/mkHost.nix`

- [ ] **Step 1: Add localzone module to the modules list**

In `lib/functions/mkHost.nix`, add after the nordvpn line:

```nix
        "${flake}/modules/nixos/services/localzone"
```

The full modules list should now be:
```nix
      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        "${flake}/modules/nixos/minimal.nix"
        "${flake}/modules/nixos/services/zerotier"
        "${flake}/modules/nixos/services/snx-rs"
        "${flake}/modules/nixos/services/nordvpn"
        "${flake}/modules/nixos/services/localzone"
        hostPath
        {
          nixpkgs.config = self.config.nixpkgs;
          nixpkgs.overlays = [ self.overlays.default ];
          home-manager.extraSpecialArgs = { inherit inputs; self = inputs.self; };
        }
      ];
```

- [ ] **Step 2: Commit**

```bash
git add lib/functions/mkHost.nix
git commit -m "chore: register localzone module in mkHost"
```

---

### Task 4: Enable localzone on peacock

**Files:**
- Modify: `machines/peacock/default.nix`

- [ ] **Step 1: Add localzone configuration**

In `machines/peacock/default.nix`, add after `modules.nordvpn.enable = true;`:

```nix
  modules.localzone = {
    enable = true;
    watchDirs = [
      "/etc/localzone/zones"
      (config.modules.localzone.dirForUser "vbargl")
    ];
  };
```

- [ ] **Step 2: Add localzone group to vbargl user**

In the `users.users.vbargl` block, add `config.modules.localzone.group` to `extraGroups`:

```nix
  users.users.vbargl = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" "video" "input" "audio" "libvirtd" "docker" "networkmanager" "nordvpn" config.modules.localzone.group ];
  };
```

- [ ] **Step 3: Commit**

```bash
git add machines/peacock/default.nix
git commit -m "feat: enable localzone on peacock"
```

---

### Task 5: Build validation

- [ ] **Step 1: Run flake check**

Run:
```bash
nix flake check
```

Expected: No errors.

- [ ] **Step 2: Build peacock configuration**

Run:
```bash
nix build .#nixosConfigurations.peacock.config.system.build.toplevel --no-link --print-out-paths
```

Expected: Build succeeds, outputs a store path.

- [ ] **Step 3: Verify localzone binary is in the system**

Run:
```bash
nix eval .#nixosConfigurations.peacock.config.systemd.services.localzone.serviceConfig.ExecStart
```

Expected: Shows a string containing `/nix/store/.../bin/localzone daemon --config /nix/store/.../localzone-config.toml`.

- [ ] **Step 4: If all checks pass, commit any remaining changes**

If build revealed issues and you fixed them, commit the fixes:
```bash
git add -A
git commit -m "fix: address build issues in localzone integration"
```
