{ pkgs, ... }:
let
  carapace-specs = pkgs.callPackage ../packages/carapace-specs { };
in
{
  xdg.configFile."carapace/specs" = {
    source = "${carapace-specs}/share/carapace/specs";
    recursive = true;
  };
}
