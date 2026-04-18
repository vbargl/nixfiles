{ lib, pkgs, config, ... }:
let
  cfg = config.programs.carapace-specs;
in
{
  options.programs.carapace-specs = {
    enable = lib.mkEnableOption "custom carapace completion specs";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.carapace-specs;
      description = "The carapace-specs package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."carapace/specs" = {
      source = "${cfg.package}/share/carapace/specs";
      recursive = true;
    };
  };
}
