# flake-parts hook: iterates `flake.users`, evaluates each registered `perUser`
# contribution once per user, hoists results to `flake.userModules.<user>.<module>`.
# Analog of flake-parts' `perSystem`.
{
  config,
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib) mkOption types mapAttrs evalModules;
in
{
  options = {
    perUser = mkOption {
      type = types.deferredModuleWith {
        staticModules = [
          {
            options.userModules = mkOption {
              type = types.lazyAttrsOf types.deferredModule;
              default = { };
              description = "NixOS modules exposed per user.";
            };
          }
        ];
      };
      default = { };
      description = ''
        Called once per user in `flake.users`.
        Args: `{ name, user, self, inputs, lib, config, ... }`.
        Set `userModules.<module-name> = <nixos-module>` to hoist into
        `flake.userModules.''${name}.<module-name>`.

        Do not read `self.userModules` from inside a `perUser` callback —
        it is the fixed point this hook is constructing, so reads trigger
        infinite recursion. Same hazard exists for `perSystem` reading
        `self.packages.''${system}`.
      '';
    };

    flake.userModules = mkOption {
      type = types.lazyAttrsOf (types.lazyAttrsOf types.unspecified);
      default = { };
      description = "Per-user NixOS modules: flake.userModules.<user>.<module>.";
    };
  };

  config.flake.userModules = mapAttrs (
    name: user:
    (evalModules {
      specialArgs = { inherit name user self inputs; };
      modules = [ config.perUser ];
    }).config.userModules
  ) config.flake.users;
}
