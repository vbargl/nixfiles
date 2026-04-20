{ lib, ... }: {
  options.flake = {
    stacks = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = "Shared NixOS machine-level composition bundles.";
    };

    users = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = "Per-user definitions exposing `.nixos` and `.modules`.";
    };

    machine.capabilities = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = "Registry of machine capability values.";
    };
  };
}
