{ lib, ... }:
{
  options.flake.deploy = lib.mkOption {
    type = lib.types.submoduleWith {
      modules = [
        {
          freeformType = lib.types.lazyAttrsOf lib.types.raw;
          options.nodes = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = { };
            description = "deploy-rs nodes.";
          };
        }
      ];
    };
    default = { };
    description = "deploy-rs top-level attribute (nodes, etc).";
  };
}
