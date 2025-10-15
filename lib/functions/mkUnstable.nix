{ inputs, ... }:
let
  inherit (inputs) self nixunstable;
in
{
  lib.mkUnstable = system: (import nixunstable { 
    inherit system; 
    config = import "${self}/nixpkgs/config.nix"; 
  });
}
