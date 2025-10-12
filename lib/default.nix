fpInputs:
let
  merge = modules: builtins.foldl' (attrset: file: attrset // (import file fpInputs)) {} modules;
  functions = [
    ./functions/mkPkgs.nix
    ./functions/mkHome.nix
  ];
in
{
  flake.lib = { inherit merge; } // (merge functions);
}
