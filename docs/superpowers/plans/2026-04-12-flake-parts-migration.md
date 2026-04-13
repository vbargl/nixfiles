# flake-parts Migration + New Module Structure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate nixfiles from nix-lite to flake-parts, restructure directories, replace home-manager with hjem, add capabilities as boolean options, and integrate stylix with rose-pine.

**Architecture:** Each file becomes a flake-parts module contributing `flake.*` or `perSystem.*` outputs. Purpose modules move to `homes/modules/`, NixOS modules to `machines/modules/`. `lib/default.nix` exposes `flake.modules.{homeManager,nixos}` via `discoverModules` (auto-discovers `.nix` files and directories). Machine configs explicitly select modules using `with self.modules.homeManager; [dev daily]`.

**Tech Stack:** Nix flakes, flake-parts, hjem, stylix (rose-pine), jujutsu (VCS)

**Working directory:** `.worktrees/flake-parts/`

---

## File Map

### Created
- `flake.nix` — complete rewrite: flake-parts, add hjem/stylix inputs, remove lite
- `lib/default.nix` — rewrite: flake-parts module exposing `discoverModules` + `flake.modules`
- `machines/modules/options.nix` — NEW: `environment.capabilities.gui` bool + `hasCapability` helper
- `machines/modules/stylix.nix` — NEW: stylix + rose-pine
- `machines/flux-capacitor.nix` — rewrite: hjem, flake-parts shape, explicit module imports
- `homes/vbargl.nix` — NEW: shared user NixOS module (moved/adapted from `homes/users/vbargl.nix`)
- `homes/modules/minimal.nix` — rewrite: `users.users.vbargl.packages` + hjem file management
- `homes/modules/dev.nix` — rewrite: `users.users.vbargl.packages`, `hasCapability`
- `homes/modules/daily.nix` — rewrite: `users.users.vbargl.packages`, `hasCapability`
- `homes/modules/connectivity.nix` — rewrite: `users.users.vbargl.packages`
- `homes/modules/games.nix` — rewrite: `users.users.vbargl.packages`, `hasCapability`
- `homes/modules/media.nix` — rewrite: `users.users.vbargl.packages`, `hasCapability`
- `homes/modules/cluster-management.nix` — rewrite: `users.users.vbargl.packages`
- `config/nushell/config.nu` — NEW: extracted from minimal.nix
- `config/nushell/env.nu` — NEW: extracted from minimal.nix

### Moved (content unchanged)
- `modules/nixos/minimal.nix` → `machines/modules/minimal.nix`
- `modules/nixos/programs/` → `machines/modules/programs/`
- `modules/nixos/services/` → `machines/modules/services/`
- `machines/flux-capacitor/hardware-configuration.nix` → `machines/hardware/flux-capacitor.nix`
- `machines/flux-capacitor/disko.nix` → `machines/hardware/flux-capacitor-disko.nix`

### Modified
- `deploy.nix` — flake-parts namespace (`flake.deploy`, `perSystem.checks`)
- `shell.nix` — flake-parts namespace (`perSystem.devShells`)
- `overlays.nix` — flake-parts namespace (`flake.overlays`)
- `config.nix` — flake-parts namespace (`flake.config`)

### Deleted
- `lib/functions/` — entire directory (mkHome, mkHost, importPkgs)
- `modules/` — entire directory (after all moves complete)
- `homes/users/` — replaced by `homes/vbargl.nix`
- `homes/default.nix` — homeConfigurations removed

---

## Task 1: Set up worktree and verify baseline

**Files:** `.worktrees/flake-parts/`

- [ ] **Step 1: Enter worktree**

```bash
cd /home/vbargl/personal/nixfiles/.worktrees/flake-parts
```

- [ ] **Step 2: Verify current flake evaluates**

```bash
nix flake show 2>&1 | head -30
```

Expected: shows `homeConfigurations`, `nixosConfigurations`, `devShells`, etc.

- [ ] **Step 3: Note current outputs for reference**

```bash
nix flake show 2>&1 > /tmp/before-outputs.txt
cat /tmp/before-outputs.txt
```

---

## Task 2: Rewrite flake.nix

**Files:** Modify `flake.nix`

- [ ] **Step 1: Replace flake.nix**

```nix
{
  description = ''
    Nix flake for managing NixOS configurations.
    Uses flake-parts for modular output composition.
    Machines include home management via hjem.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
    ];
  };
}
```

- [ ] **Step 2: Verify flake inputs parse (will fail on outputs — expected)**

```bash
nix flake metadata 2>&1 | head -20
```

Expected: shows resolved inputs (may error on outputs — that's fine, we'll fix outputs next).

---

## Task 3: Create lib/default.nix with discoverModules

**Files:** Rewrite `lib/default.nix`

- [ ] **Step 1: Write lib/default.nix**

```nix
{ lib, ... }:
let
  discoverModules = dir:
    let
      entries = builtins.readDir dir;
      nixFiles = lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
        entries;
      dirs = lib.filterAttrs
        (name: type: type == "directory")
        entries;
    in
    lib.mapAttrs'
      (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (dir + "/${name}"))
      nixFiles
    //
    lib.mapAttrs
      (name: _: dir + "/${name}")
      dirs;
in
{
  flake.modules = {
    homeManager = discoverModules ../homes/modules;
    nixos       = discoverModules ../machines/modules;
  };
}
```

- [ ] **Step 2: Delete old lib functions directory**

```bash
rm -rf lib/functions
```

---

## Task 4: Move NixOS modules to machines/modules/

**Files:** Move `modules/nixos/` → `machines/modules/`

- [ ] **Step 1: Create machines/modules/ directory structure**

```bash
mkdir -p machines/modules
```

- [ ] **Step 2: Move files**

```bash
mv modules/nixos/minimal.nix machines/modules/minimal.nix
mv modules/nixos/programs machines/modules/programs
mv modules/nixos/services machines/modules/services
```

- [ ] **Step 3: Move hardware files**

```bash
mkdir -p machines/hardware
mv machines/flux-capacitor/hardware-configuration.nix machines/hardware/flux-capacitor.nix
mv machines/flux-capacitor/disko.nix machines/hardware/flux-capacitor-disko.nix
```

---

## Task 5: Create machines/modules/options.nix

**Files:** Create `machines/modules/options.nix`

- [ ] **Step 1: Write options.nix**

```nix
{ lib, config, ... }: {
  options.environment.capabilities = {
    gui = lib.mkEnableOption "graphical environment (display server, GUI apps)";
  };

  config._module.args.hasCapability = cap:
    config.environment.capabilities.${cap} or false;
}
```

---

## Task 6: Create machines/modules/stylix.nix

**Files:** Create `machines/modules/stylix.nix`

- [ ] **Step 1: Write stylix.nix**

```nix
{ inputs, pkgs, lib, config, ... }:
lib.mkIf config.environment.capabilities.gui {
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

---

## Task 7: Move purpose modules to homes/modules/

**Files:** Move `modules/home-manager/modules/` → `homes/modules/`

- [ ] **Step 1: Create homes/modules/ directory**

```bash
mkdir -p homes/modules
```

- [ ] **Step 2: Move all purpose module files**

```bash
mv modules/home-manager/modules/connectivity.nix homes/modules/connectivity.nix
mv modules/home-manager/modules/dev.nix homes/modules/dev.nix
mv modules/home-manager/modules/daily.nix homes/modules/daily.nix
mv modules/home-manager/modules/games.nix homes/modules/games.nix
mv modules/home-manager/modules/media.nix homes/modules/media.nix
mv modules/home-manager/modules/cluster-management.nix homes/modules/cluster-management.nix
mv modules/home-manager/modules/minimal.nix homes/modules/minimal.nix
# move any other modules present
mv modules/home-manager/modules/helix.nix homes/modules/helix.nix 2>/dev/null || true
mv modules/home-manager/modules/caelestia.nix homes/modules/caelestia.nix 2>/dev/null || true
mv modules/home-manager/modules/carapace-specs.nix homes/modules/carapace-specs.nix 2>/dev/null || true
```

---

## Task 8: Rewrite homes/modules/connectivity.nix

**Files:** Rewrite `homes/modules/connectivity.nix`

- [ ] **Step 1: Replace content**

```nix
{ pkgs, ... }: {
  users.users.vbargl.packages = with pkgs; [
    zerotierone
    snx-rs
    nordvpn
  ];
}
```

Key changes:
- Removed `lib.mkIf hasConnectivityPurpose` — module is only imported when connectivity is selected
- `home.packages` → `users.users.vbargl.packages`

---

## Task 9: Rewrite homes/modules/cluster-management.nix

**Files:** Rewrite `homes/modules/cluster-management.nix`

- [ ] **Step 1: Replace content**

```nix
{ pkgs, ... }: {
  users.users.vbargl.packages = with pkgs; [
    k9s
    kubectl
    age
    deploy-rs
  ];
}
```

---

## Task 10: Rewrite homes/modules/games.nix

**Files:** Rewrite `homes/modules/games.nix`

- [ ] **Step 1: Replace content**

```nix
{ pkgs, hasCapability, lib, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
    steam
    moonlight-qt
  ];
}
```

---

## Task 11: Rewrite homes/modules/media.nix

**Files:** Rewrite `homes/modules/media.nix`

- [ ] **Step 1: Replace content**

```nix
{ pkgs, hasCapability, lib, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
    vlc
    mpv
    feh
    spotify
  ];
}
```

---

## Task 12: Rewrite homes/modules/daily.nix

**Files:** Rewrite `homes/modules/daily.nix`

- [ ] **Step 1: Replace content**

```nix
{ pkgs, lib, hasCapability, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
    wl-clipboard
    alsa-utils
    xwayland
    hyprland
    pavucontrol
    hyprlock
    hypridle
    hyprsysteminfo
    hyprcursor
    xdg-desktop-portal-hyprland
    brightnessctl
    playerctl
    pamixer
    libnotify
    grim
    slurp
    swappy
    gpu-screen-recorder
    kdePackages.dolphin
    keepassxc
    winbox4
    rustdesk
    onlyoffice-desktopeditors
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  systemd.user.services.syncthing = {
    description = "Syncthing";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing serve --no-browser --config /home/vbargl/.config/syncthing --data /home/vbargl/Sync";
      Restart = "on-failure";
    };
  };
}
```

Note: `services.syncthing` (home-manager) → `systemd.user.services.syncthing` (NixOS).

---

## Task 13: Rewrite homes/modules/dev.nix

**Files:** Rewrite `homes/modules/dev.nix`

- [ ] **Step 1: Replace content**

```nix
{ lib, pkgs, hasCapability, ... }: {
  users.users.vbargl.packages = with pkgs; lib.mkMerge [
    [
      jujutsu
      git
      git-credential-keepassxc
      lazygit
      nixd
      xvfb-run
      ngrok
      kind
      nodejs
      pinchtab
    ]
    (lib.mkIf (hasCapability "gui") [
      vscode
      code-cursor
      jetbrains.idea
      jetbrains.goland
      jetbrains.rider
      jetbrains.webstorm
      android-studio
      postman
      realvnc-vnc-viewer
      remmina
      google-chrome
      p11-kit
    ])
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

Note: `programs.direnv` with `nix-direnv` support exists as a NixOS module. Verify it's available in nixpkgs; if not, install `direnv` + `nix-direnv` via packages and configure shell manually.

---

## Task 14: Extract nushell config to files

**Files:** Create `config/nushell/env.nu` and `config/nushell/config.nu`

The current `homes/modules/minimal.nix` has nushell config inline in `programs.nushell.extraEnv` and `programs.nushell.extraConfig`. Extract these to standalone files.

- [ ] **Step 1: Create config/nushell/ directory**

```bash
mkdir -p config/nushell
```

- [ ] **Step 2: Create config/nushell/env.nu**

Extract the content from `programs.nushell.extraEnv` in the current `minimal.nix`:

```nushell
# Carapace bridges - use completions from other shells for commands
# carapace doesn't natively support
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

# nupm
let bin = ($env.HOME | path join ".local" "bin")
$env.NUPM_HOME = ($env.XDG_DATA_HOME? | default ($env.HOME | path join ".local" "share") | path join "nupm")

$env.NU_LIB_DIRS = (
    $env.NU_LIB_DIRS?
    | default []
    | append ($env.NUPM_HOME | path join "modules")
    | append ($env.HOME | path join ".local" "share" "nupm-repo")
)

$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend ($env.NUPM_HOME | path join "scripts")
    | uniq
)

$env.PATH = (
    $env.PATH
    | append $bin
)

# Rose Pine Moon prompt
$env.PROMPT_COMMAND = {||
    let red = (ansi {fg: '#eb6f92'})
    let gold = (ansi {fg: '#f6c177'})
    let pine = (ansi {fg: '#31748f'})
    let iris = (ansi {fg: '#c4a7e7'})
    let overlay = (ansi {fg: '#6e6a86'})
    let reset = (ansi reset)

    let user = (whoami | str trim)
    let host = (hostname | str trim | split row '.' | first)
    let dir = if ($env.PWD | str starts-with $env.HOME) {
        $env.PWD | str replace $env.HOME '~'
    } else {
        $env.PWD
    }

    let branch_text = if (which jj | is-not-empty) {
        let jj_info = (^jj log -r @ --no-graph -T 'separate(" ", bookmarks.join(", "), change_id.shortest(8))' | complete)
        if $jj_info.exit_code == 0 {
            let info = ($jj_info.stdout | str trim)
            if ($info | is-empty) { "" } else { $"jj:($info)" }
        } else {
            ""
        }
    } else {
        let git_branch = (^git symbolic-ref --short HEAD | complete)
        if $git_branch.exit_code == 0 {
            ($git_branch.stdout | str trim)
        } else {
            ""
        }
    }

    let datetime = (date now | format date "%Y-%m-%d %H:%M")

    let left_text = $"($user)@($host) ($dir)"
    let right_text = if ($branch_text | is-empty) {
        $datetime
    } else {
        $"($branch_text) ($datetime)"
    }

    let width = (term size).columns
    let padding = ([1, ($width - ($left_text | str length) - ($right_text | str length))] | math max)
    let spaces = (''' | fill -c ' ' -w $padding)

    let left = $"($red)($user)($overlay)@($host) ($pine)($dir)($reset)"
    let right = if ($branch_text | is-empty) {
        $"($iris)($datetime)($reset)"
    } else {
        $"($gold)($branch_text) ($iris)($datetime)($reset)"
    }

    $"($left)($spaces)($right)"
}

$env.PROMPT_INDICATOR = {||
    let gold = (ansi {fg: '#f6c177'})
    let red = (ansi {fg: '#eb6f92'})
    let reset = (ansi reset)

    if ($env.LAST_EXIT_CODE? | default 0) == 0 {
        $"\n($gold)✔$ ($reset)"
    } else {
        $"\n($red)✗$ ($reset)"
    }
}

$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_MULTILINE_INDICATOR = {|| "  " }
```

- [ ] **Step 3: Create config/nushell/config.nu**

Extract the content from `programs.nushell.extraConfig` in the current `minimal.nix`:

```nushell
# Override carapace completer with CARAPACE_LENIENT to prevent errors
# on unknown flags and improve overall completion experience
let carapace_completer = {|spans: list<string>|
  # expand aliases
  let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)
  let spans = (if $expanded_alias != null {
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans
  | from json
  | default []
}

$env.config.completions.external.completer = $carapace_completer
```

---

## Task 15: Rewrite homes/modules/minimal.nix

**Files:** Rewrite `homes/modules/minimal.nix`

- [ ] **Step 1: Replace content**

```nix
{ lib, pkgs, hasCapability, ... }: {
  users.users.vbargl.packages = with pkgs; lib.mkMerge [
    [
      moreutils
      nmap
      curl
      fzf
      rclone
      dasel
      bat
      btop
      gtrash
      zip
      unzip
      fd
      bc
      less
      nh
      nushell
      fish
      carapace
      yazi
      zellij
    ]
    (lib.mkIf (hasCapability "gui") [
      ghostty
      walker
      firefox
      thunderbird
      peazip
    ])
  ];

  programs.fish.enable = true;

  hjem.users.vbargl.files = {
    ".config/nushell/env.nu".source    = ../../config/nushell/env.nu;
    ".config/nushell/config.nu".source = ../../config/nushell/config.nu;
  };
}
```

Note: `programs.carapace`, `programs.yazi`, `programs.zellij` — install packages only; config files added via hjem as needed. `programs.fish.enable = true` is a valid NixOS option.

---

## Task 16: Create homes/vbargl.nix

**Files:** Create `homes/vbargl.nix`

- [ ] **Step 1: Write homes/vbargl.nix**

```nix
{ pkgs, lib, ... }: {
  users.users.vbargl = {
    isNormalUser = true;
    hashedPassword = null;
    shell = lib.mkDefault pkgs.nushell;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzfPQUzXyHZZL1sfHzCA0o5eKdsL+/XrHrVJnAt9liI vbargl@peacock"
    ];
  };

  environment.shells = lib.mkDefault [ pkgs.nushell ];
}
```

Note: `home.stateVersion`, `home.username`, `home.homeDirectory` were home-manager options — not needed in NixOS context. The nix registry activation script from the old `vbargl.nix` is dropped (handled by nix settings or user manually).

---

## Task 17: Rewrite machines/flux-capacitor.nix

**Files:** Create `machines/flux-capacitor.nix`, delete `machines/flux-capacitor/` directory

- [ ] **Step 1: Create machines/flux-capacitor.nix**

```nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.flux-capacitor = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = { inherit inputs self; };

    modules = [
      inputs.hjem.nixosModules.hjem
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko

      ./hardware/flux-capacitor.nix
      ./hardware/flux-capacitor-disko.nix

      ../homes/vbargl.nix

    ] ++ (with self.modules.nixos; [
      options
      minimal
      stylix
      services
    ]) ++ (with self.modules.homeManager; [
      minimal
      connectivity
      daily
    ]) ++ [{
      nixpkgs.config = self.config.nixpkgs;
      nixpkgs.overlays = [ self.overlays.default ];

      environment.capabilities.gui = true;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "root" "vbargl" ];
      };

      modules.zerotier = {
        enable = true;
        networkIds = [ "b6079f73c6fe0b88" ];
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 20;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelModules = [ "dm_crypt" ];

      networking.hostName = "flux-capacitor";
      networking.networkmanager.enable = true;
      networking.networkmanager.ensureProfiles.environmentFiles = [
        config.age.secrets.wifi-vodafone-psk.path
      ];
      networking.networkmanager.ensureProfiles.profiles.vodafone = {
        connection = { id = "Vodafone-D064"; type = "wifi"; interface-name = "wlo1"; };
        wifi = { mode = "infrastructure"; ssid = "Vodafone-D064"; };
        wifi-security = { auth-alg = "open"; key-mgmt = "wpa-psk"; psk = "$WIFI_VODAFONE_PSK"; };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      age.secrets.wifi-vodafone-psk.file = ../../secrets/wifi-vodafone-psk.age;
      age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

      i18n.defaultLocale = "cs_CZ.UTF-8";
      i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";
      console.keyMap = "cz-qwertz";

      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.autoLogin = { enable = true; user = "vbargl"; };
      services.desktopManager.plasma6.enable = true;
      services.xserver.xkb = { layout = "cz"; variant = "qwerty"; };

      security.rtkit.enable = true;
      services.pipewire = { enable = true; audio.enable = true; pulse.enable = true; alsa.enable = true; };

      hardware.bluetooth.enable = true;

      security.sudo.extraRules = [{
        users = [ "vbargl" ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
      }];

      hjem.users.vbargl.directory = "/home/vbargl";

      services.k3s = {
        enable = true;
        role = "server";
        tokenFile = config.age.secrets.k3s-token.path;
        extraFlags = [ "--tls-san=172.27.27.9" ];
      };

      services.openiscsi = { enable = true; name = "iqn.2026-03.net.barglvojtech:flux-capacitor"; };

      systemd.tmpfiles.rules = [
        "L+ /usr/local/bin/iscsiadm - - - - \${pkgs.openiscsi}/bin/iscsiadm"
      ];

      programs.firefox.enable = true;

      environment.systemPackages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
        vim btop curl git nfs-utils util-linux
      ];

      systemd.services.rustdesk = {
        description = "RustDesk remote desktop service";
        requires = [ "network-online.target" ];
        after = [ "systemd-user-sessions.service" "network-online.target" "display-manager.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "graphical.target" ];
        script = ''
          export PATH=/run/wrappers/bin:$PATH
          ''${pkgs.rustdesk-flutter}/bin/rustdesk --service
        '';
        serviceConfig = { Type = "simple"; Restart = "always"; RestartSec = 5; };
      };

      services.openssh = { enable = true; settings = { PermitRootLogin = "no"; PasswordAuthentication = false; }; };

      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 6443 21115 21116 21117 21118 ];
      networking.firewall.allowedUDPPorts = [ 21116 ];

      system.stateVersion = "25.11";
    }];
  };
}
```

- [ ] **Step 2: Check that machines/ has a default.nix for flake-parts to import**

Create `machines/default.nix` as a flake-parts module that imports all machine files:

```nix
{ ... }: {
  imports = [
    ./flux-capacitor.nix
  ];
}
```

- [ ] **Step 3: Remove old machines/flux-capacitor/ directory**

```bash
rm -rf machines/flux-capacitor
```

---

## Task 18: Update deploy.nix

**Files:** Modify `deploy.nix`

- [ ] **Step 1: Rewrite to flake-parts namespace**

```nix
{ self, inputs, ... }:
let
  inherit (inputs) deploy-rs;
  system = "x86_64-linux";
in
{
  flake.deploy.nodes.flux-capacitor = {
    hostname = "flux-capacitor";
    sshUser = "vbargl";
    user = "root";
    sshOpts = [ "-o" "StrictHostKeyChecking=no" ];
    magicRollback = true;
    autoRollback = true;
    confirmTimeout = 300;

    profiles.system = {
      path = deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations.flux-capacitor;
    };
  };

  perSystem = { system, ... }: {
    checks = deploy-rs.lib.${system}.deployChecks self.deploy;
  };
}
```

---

## Task 19: Update shell.nix

**Files:** Modify `shell.nix`

- [ ] **Step 1: Rewrite to flake-parts perSystem**

```nix
{ inputs, ... }: {
  perSystem = { system, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs.deploy-rs.packages.${system}.default
      ];
    };
  };
}
```

---

## Task 20: Update overlays.nix

**Files:** Modify `overlays.nix`

- [ ] **Step 1: Rewrite to flake-parts namespace**

```nix
{ self, inputs, ... }: {
  flake.overlays.default = final: prev:
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
}
```

---

## Task 21: Update config.nix

**Files:** Modify `config.nix`

- [ ] **Step 1: Read current config.nix**

```bash
cat config.nix
```

- [ ] **Step 2: Wrap in flake-parts namespace**

Current content is `{ config.nixpkgs = { allowUnfree = true; ... }; }`. In flake-parts this becomes:

```nix
{ ... }: {
  flake.config = {
    nixpkgs = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}
```

---

## Task 22: Remove old directory structure

**Files:** Delete `modules/`, `homes/users/`, `homes/default.nix`, `lib/functions/`

- [ ] **Step 1: Remove old modules directory (now empty)**

```bash
rm -rf modules
```

- [ ] **Step 2: Remove old homes structure**

```bash
rm -rf homes/users
rm -f homes/default.nix
```

- [ ] **Step 3: Verify working tree**

```bash
ls -la
```

Expected top-level: `flake.nix`, `lib/`, `homes/`, `machines/`, `packages/`, `devshells/`, `config/`, `assets/`, `secrets/`, `deploy.nix`, `shell.nix`, `overlays.nix`, `config.nix`

---

## Task 23: Update flake.lock and verify

**Files:** `flake.lock`

- [ ] **Step 1: Update flake.lock for new inputs**

```bash
nix flake update --commit-lock-file 2>&1 | tail -20
```

- [ ] **Step 2: Check flake structure**

```bash
nix flake show 2>&1
```

Expected: `nixosConfigurations.flux-capacitor`, `devShells.x86_64-linux.default`, `overlays.default`, `deploy.*`

- [ ] **Step 3: Attempt to build nixos config (may reveal errors to fix)**

```bash
nix build .#nixosConfigurations.flux-capacitor.config.system.build.toplevel --no-link 2>&1 | head -50
```

- [ ] **Step 4: Commit when build succeeds**

```bash
jj describe -m "feat: migrate to flake-parts, hjem, stylix, new module structure"
jj new -m ""
```

---

## Task 24: Fix build errors (expected)

This task covers fixing issues that arise during Task 23. Common expected errors:

**`self.config` not found:** `self.config.nixpkgs` — in flake-parts, `self.config` is `self.flake.config` (if you expose it). Update references in overlays and machine configs:
- In `overlays.nix`: use `self.flake.config.nixpkgs` or pass config directly
- In machine config: use `inputs.nixpkgs.config` pattern or set inline

**`self.modules` undefined before lib evaluates:** Ensure `./lib` is listed first in `flake.nix` imports, or accept evaluation order from flake-parts (lazy).

**`hjem.users.vbargl.directory` missing:** Check hjem's actual option name by running:
```bash
nix eval --impure --expr '(import <nixpkgs> {}).lib.optionAttrSetToDocList (import (builtins.fetchTarball "https://github.com/feel-co/hjem/archive/main.tar.gz") {}).nixosModules.hjem {}' 2>&1 | head -30
```
Or check hjem docs at `github.com/feel-co/hjem`.

**Purpose module options not found:** If `users.users.vbargl.packages` is not a valid NixOS option (it's `users.users.<name>.packages` which may require `users.users.vbargl` to be defined first — it is in `homes/vbargl.nix` but load order matters). Fix: use `environment.systemPackages` or ensure user is defined before packages.

- [ ] **Step 1: Run build and capture errors**

```bash
nix build .#nixosConfigurations.flux-capacitor.config.system.build.toplevel --no-link 2>&1 > /tmp/build-errors.txt
cat /tmp/build-errors.txt | head -80
```

- [ ] **Step 2: Fix errors one by one, re-run build after each fix**

- [ ] **Step 3: When build succeeds, commit**

```bash
jj describe -m "fix: resolve build errors from flake-parts migration"
jj new -m ""
```
