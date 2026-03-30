# animus

Lightweight NixOS VM for testing K3s and Longhorn deployments before applying to production (flux-capacitor).

## Purpose

- Validate Longhorn storage provisioning on NixOS
- Test nuke manifest rendering and deployment
- Verify K3s cluster setup and wave ordering

## Specs

- **Type:** QEMU VM (nixos-rebuild build-vm)
- **K3s:** Single-node server, local-storage and traefik disabled
- **Longhorn deps:** open-iscsi, nfs-utils, iscsiadm symlink fix
- **No:** home-manager, zerotier, agenix, disko

## Usage

Build and run:

```bash
cd ~/personal/nixfiles

# Build
nixos-rebuild build-vm --flake .#animus

# Run (20GB disk, 4GB RAM, 2 cores, SSH + K3s port forwarding)
TEMP=$(mktemp)
qemu-img create -f raw "$TEMP" 20G
mkfs.ext4 -L nixos "$TEMP"
qemu-img convert -f raw -O qcow2 "$TEMP" /tmp/animus.qcow2
rm "$TEMP"

NIX_DISK_IMAGE=/tmp/animus.qcow2 \
QEMU_NET_OPTS="hostfwd=tcp::2222-:22,hostfwd=tcp::6443-:6443" \
  result/bin/run-animus-vm -m 4096 -smp 2 -nographic
```

Access:

```bash
# SSH
ssh -p 2222 vbargl@localhost

# Kubeconfig
ssh -p 2222 vbargl@localhost "bash -c 'sudo cat /etc/rancher/k3s/k3s.yaml'" \
  | sed 's|127.0.0.1|localhost|' > /tmp/animus-kubeconfig.yaml
export KUBECONFIG=/tmp/animus-kubeconfig.yaml
```

## NixOS + Longhorn gotcha

Longhorn uses `nsenter` into the host mount namespace to find `iscsiadm`. On NixOS, binaries live under `/nix/store/`, not in standard paths. The fix:

```nix
systemd.tmpfiles.rules = [
  "L+ /usr/local/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
];
```

This applies to any NixOS machine running Longhorn (including flux-capacitor).
