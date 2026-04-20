{
  flake.homeModules.carapace-specs = { lib, pkgs, config, ... }:
    let
      cfg = config.nxf.home.carapace-specs;
    in
    {
      options.nxf.home.carapace-specs.package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.carapace-specs;
        description = "The carapace-specs package to use";
      };

      config = {
        xdg.configFile."carapace/specs" = {
          source = "${cfg.package}/share/carapace/specs";
          recursive = true;
        };
      };
    };
}
