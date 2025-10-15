# lite/systems.nix
#
# System utilities for per-system evaluation.
#
# Exports:
#   - lite.systems.for  :: [system] -> (system -> result) -> { "<system>" = result; ... }
#   - lite.systems.each :: (system -> result) -> { "<system>" = result; ... }
#
# Configured systems are read from lite.config.systems.
#
lite:
let
  # Pull configured systems or default fallback
  systems =
    if lite ? config && lite.config ? systems
    then lite.config.systems
    else [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

  # Map explicit list of systems → attrset
  for = sysList: f:
    builtins.listToAttrs (builtins.map (s: { name = s; value = f s; }) sysList);

  # Map configured systems → attrset
  each = f: for systems f;
in
{
  inherit for each;
}
